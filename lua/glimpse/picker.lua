local UI = require("glimpse.ui")
local fuzzy = require("glimpse.fuzzy")
local util = require("glimpse.util")
local api = vim.api

---@class ActionTable
---@field refresh fun() Refresh the picker
---@field next_item fun() Move to next item
---@field prev_item fun() Move to previous item
---@field complete_selection fun() Complete current selection
---@field toggle_mark fun() Toggle mark on current item
---@field select_input fun() Select raw input
---@field select_entry fun() Select current entry
---@field close fun() Close the picker

---@class GlimpseOptions
---@field prompt? string Prompt text (default: "> ")
---@field on_select? fun(selection: string, data: table|nil) Callback when item selected
---@field on_close? fun() Callback when picker closes
---@field on_change? fun(query: string, callback: fun(matches: table)) Live query handler
---@field parser? fun(selection: string): table|nil Parse selection into structured data
---@field selection_format? string Predefined format: "file", "grep", "lsp", "buffer"
---@field keymaps? table<string, string> Keymap overrides (key → action name)
---@field layout? table Layout options for UI
---@field debounce_ms? integer Debounce delay for async providers (default: 100)
---@field min_query_len? integer Minimum query length before running async command (default: 2)
---@field post_process? fun(lines: string[], query: string): string[] Post-process async results

---@class Picker
---@field items_or_provider table|fun(query: string): table
---@field opts GlimpseOptions
---@field on_select fun(selection: string, data: table|nil)
---@field original_win integer
---@field original_buf integer
---@field original_cursor integer[]
---@field parser fun(selection: string): table|nil|nil
---@field current_matches string[]
---@field current_query string
---@field marked table<string, boolean>
---@field selected_index integer
---@field is_previewing boolean
---@field debounce_timer uv.uv_timer_t?
---@field preview_timer uv.uv_timer_t?
---@field ui GlimpseUI
---@field input_buf integer|nil
---@field actions ActionTable
local Picker = {}
Picker.__index = Picker

---@type Picker|nil Currently active picker instance
local active_picker = nil

---Close any existing picker and clean up windows
function Picker.close_existing()
    if active_picker then
        active_picker:close()
        active_picker = nil
    end

    for _, win in ipairs(api.nvim_list_wins()) do
        if api.nvim_win_is_valid(win) then
            local buf = api.nvim_win_get_buf(win)
            local ft = vim.bo[buf].filetype

            if ft == "glimpse_input" or ft == "glimpse_results" then
                api.nvim_win_close(win, true)
            end
        end
    end
end

---Create a new Picker instance
---@param items_or_provider table|fun(query: string): table List of strings or provider function
---@param opts GlimpseOptions|nil Configuration options
---@return Picker picker New picker instance
function Picker.new(items_or_provider, opts)
    Picker.close_existing()

    ---@type Picker
    local self = setmetatable({}, Picker)

    self.items_or_provider = items_or_provider
    self.opts = opts or {}
    self.on_select = self.opts.on_select

    self.original_win = api.nvim_get_current_win()
    self.original_buf = api.nvim_win_get_buf(self.original_win)
    self.original_cursor = api.nvim_win_get_cursor(self.original_win)

    self.parser = self.opts.parser

    if not self.parser and self.opts.selection_format then
        self.parser = function(s)
            return util.parse_selection(s, self.opts.selection_format)
        end
    end

    self.current_matches = {}
    self.current_query = ""
    self.marked = {}
    self.selected_index = 1
    self.is_previewing = false
    self.debounce_timer = nil
    self.preview_timer = nil

    self.ui = UI.new(self.opts.prompt or "> ", {
        layout = self.opts.layout,
        parser = self.parser,
    })

    self.input_buf = nil

    active_picker = self

    return self
end

---Create a new async Picker that runs an external command per query
---@param command_generator fun(query: string): string[]|nil Returns command args to run
---@param opts GlimpseOptions|nil Configuration options
---@return Picker picker New picker instance
function Picker.new_async(command_generator, opts)
    opts = opts or {}
    local original_on_close = opts.on_close
    local debounce_ms = opts.debounce_ms or 100
    local min_query_len = opts.min_query_len or 2
    local post_process = opts.post_process

    ---@type vim.SystemObj?
    local current_job = nil
    ---@type uv.uv_timer_t?
    local async_timer = nil

    local function cleanup()
        if current_job then
            current_job:kill(15)
            current_job = nil
        end

        if async_timer then
            async_timer:stop()
            async_timer:close()
            async_timer = nil
        end
    end

    opts.on_close = function()
        cleanup()

        if original_on_close then
            original_on_close()
        end
    end

    opts.on_change = function(query, update_ui_callback)
        cleanup()

        if not query or #query < min_query_len then
            update_ui_callback({})

            return
        end

        async_timer = vim.uv.new_timer()
        if not async_timer then
            return
        end

        async_timer:start(
            debounce_ms,
            0,
            vim.schedule_wrap(function()
                async_timer:close()
                async_timer = nil

                local cmd = command_generator(query)

                if not cmd then
                    update_ui_callback({})

                    return
                end

                local output_lines = {}
                local this_job

                this_job = vim.system(cmd, {
                    text = true,
                    stdout = function(_, data)
                        if not data then
                            return
                        end

                        local lines = vim.split(data, "\n", { trimempty = true })

                        for _, line in ipairs(lines) do
                            table.insert(output_lines, line)
                        end

                        vim.schedule(function()
                            if current_job ~= this_job then
                                return
                            end

                            local matches = output_lines

                            if post_process then
                                matches = post_process(output_lines, query)
                            end

                            update_ui_callback(matches)
                        end)
                    end,
                })
                current_job = this_job
            end)
        )
    end

    return Picker.new({}, opts)
end

---Show the picker UI
function Picker:show()
    local input_buf, _ = self.ui:create_windows()
    self.input_buf = input_buf

    self:setup_actions()
    self:setup_keymaps()
    self:setup_autocmds()

    self:refresh()
    vim.cmd("startinsert")
end

---Close the picker and clean up resources
function Picker:close()
    if self.debounce_timer then
        self.debounce_timer:stop()
        self.debounce_timer:close()
        self.debounce_timer = nil
    end

    if self.preview_timer then
        self.preview_timer:stop()
        self.preview_timer:close()
        self.preview_timer = nil
    end

    if not self.ui then
        return
    end

    if self.opts.on_close then
        self.opts.on_close()
    end

    if api.nvim_win_is_valid(self.original_win) and api.nvim_buf_is_valid(self.original_buf) then
        api.nvim_win_set_buf(self.original_win, self.original_buf)
    end

    self.ui:close()

    if active_picker == self then
        active_picker = nil
    end

    self.current_matches = nil
    self.items_or_provider = nil
    self.marked = nil
end

---Cancel picker and restore original state
function Picker:cancel()
    if api.nvim_win_is_valid(self.original_win) and api.nvim_buf_is_valid(self.original_buf) then
        api.nvim_win_set_buf(self.original_win, self.original_buf)
        api.nvim_win_set_cursor(self.original_win, self.original_cursor)
    end

    self:close()
end

---Update preview window with current selection
function Picker:update_preview()
    if #self.current_matches == 0 then
        return
    end

    if self.preview_timer then
        self.preview_timer:stop()
    else
        self.preview_timer = vim.uv.new_timer()
    end

    if not self.preview_timer then
        return
    end

    self.preview_timer:start(
        50,
        0,
        vim.schedule_wrap(function()
            ---@diagnostic disable-next-line: unnecessary-if
            if self.preview_timer then
                self.preview_timer:stop()
                self.preview_timer:close()
                self.preview_timer = nil
            end

            if not active_picker or active_picker ~= self then
                return
            end

            local selection = self.current_matches[self.selected_index]

            if not selection then
                return
            end

            self.is_previewing = true
            self.ui:show_preview(selection)
            self.is_previewing = false
        end)
    )
end

---Render current matches to the UI
function Picker:render()
    self.ui:render(self.current_matches, self.selected_index, self.marked, self.current_query)
    self:update_preview()
end

---Refresh matches based on current input
function Picker:refresh()
    if self.debounce_timer then
        self.debounce_timer:stop()
    else
        self.debounce_timer = vim.uv.new_timer()
    end

    if not self.debounce_timer then
        return
    end

    local input = api.nvim_get_current_line()
    self.current_query = input

    self.debounce_timer:start(
        20,
        0,
        vim.schedule_wrap(function()
            ---@diagnostic disable-next-line: unnecessary-if
            if self.debounce_timer then
                self.debounce_timer:stop()
                self.debounce_timer:close()
                self.debounce_timer = nil
            end

            if not active_picker or active_picker ~= self then
                return
            end

            if self.opts.on_change then
                self.opts.on_change(input, function(matches)
                    if api.nvim_get_current_line() ~= input then
                        return
                    end

                    if active_picker ~= self then
                        return
                    end

                    self.current_matches = matches or {}
                    self.selected_index = 1
                    self:render()
                end)

                return
            end

            self.current_matches = fuzzy.filter(self.items_or_provider, input)

            self.selected_index = 1
            self:render()
        end)
    )
end

---Setup all picker actions
function Picker:setup_actions()
    self.actions = {}

    self.actions.refresh = function()
        self:refresh()
    end

    self.actions.next_item = function()
        if #self.current_matches > 0 then
            self.selected_index = (self.selected_index % #self.current_matches) + 1
            self:render()
        end
    end

    self.actions.prev_item = function()
        if #self.current_matches > 0 then
            self.selected_index = ((self.selected_index - 2) % #self.current_matches) + 1
            self:render()
        end
    end

    self.actions.complete_selection = function()
        local selection = self.current_matches[self.selected_index]
        local input = api.nvim_get_current_line()

        if selection then
            local new_line = util.complete_line(input, selection)
            self.ui:update_input({ new_line })
            self:refresh()
        end
    end

    self.actions.toggle_mark = function()
        local selection = self.current_matches[self.selected_index]
        if selection then
            self.marked[selection] = not self.marked[selection]
            self.ui:render(self.current_matches, self.selected_index, self.marked)
        end

        self.actions.next_item()
    end

    self.actions.select_input = function()
        local current_input = api.nvim_get_current_line()
        self:close()

        if self.on_select and current_input ~= "" then
            self.on_select(current_input, nil)
        end
    end

    self.actions.select_entry = function()
        local selection = self.current_matches[self.selected_index]

        if selection then
            self:close()

            local data = self.parser and self.parser(selection)

            self.on_select(selection, data)
        end
    end

    self.actions.close = function()
        self:cancel()
    end
end

---Update the items in the picker and re-filter
---@param new_items string[]
function Picker:set_items(new_items)
    self.items_or_provider = new_items
    self:refresh()
end

---Setup keymaps for the picker
function Picker:setup_keymaps()
    local default_keymaps = {
        ["<Tab>"] = "toggle_mark",
        ["<C-n>"] = "next_item",
        ["<C-p>"] = "prev_item",
        ["<Down>"] = "next_item",
        ["<Up>"] = "prev_item",
        ["<CR>"] = "select_entry",
        ["<Esc>"] = "close",
        ["<C-c>"] = "close",
    }

    local keymaps = vim.tbl_extend("force", default_keymaps, self.opts.keymaps or {})

    for key, action in pairs(keymaps) do
        if self.actions[action] then
            keys.bmap(key, self.actions[action], "", self.input_buf, "i")
        end
    end
end

---Setup autocommands for the picker
function Picker:setup_autocmds()
    local group = ev.group("GlimpseLive")

    ev.on(ev.TextChangedI, function()
        self:refresh()
    end, {
        buffer = self.input_buf,
        group = group,
    })

    ev.on(ev.WinLeave, function()
        if self.is_previewing then
            return
        end

        self:cancel()
    end, {
        buffer = self.input_buf,
        group = group,
    })
end

return Picker
