local highlight = require("glimpse.highlight")

local M = {}

local function ensure_highlights()
    local function set_default(name, opts)
        opts.default = true
        vim.api.nvim_set_hl(0, name, opts)
    end

    set_default("GlimpseNormal", { fg = colors.none, bg = colors.black.dim })
    set_default("GlimpseBorder", { fg = colors.gray.base })
    set_default("GlimpsePrompt", { link = "DiagnosticOk" })
    set_default("GlimpseCursorLine", { bg = colors.black.base })
    set_default("GlimpseMatch", { fg = colors.cyan.bright, bold = true })
    set_default("GlimpseDirectory", { fg = colors.gray.bright })
    set_default("GlimpseLineNr", { link = "LineNr" })
    set_default("GlimpseCounter", { bg = colors.black.dim })
end

---@class GlimpseLayoutOpts
---@field width? number Fraction of screen width (default: 0.85)
---@field height? number Fraction of screen height (default: 0.85)
---@field preview_height? number Fraction of picker height for preview (default: 0.4)
---@field border? string Border style (default: "rounded")

---@class GlimpseUI
---@field base_prompt string
---@field ns_id integer
---@field prompt_ns integer
---@field preview_ns integer
---@field layout_opts GlimpseLayoutOpts
---@field parser? function
---@field preview_buf? integer
---@field preview_win? integer
---@field results_buf? integer
---@field results_win? integer
---@field input_buf? integer
---@field input_win? integer
---@field augroup? integer
---@field current_preview_file? string
local UI = {}
UI.__index = UI

local default_layout = {
    width = 0.85,
    height = 0.85,
    preview_height = 0.4,
}

local borders = {
    preview = { "┌", "─", "┐", "│", "┤", "─", "├", "│" },
    results = { " ", " ", " ", "│", " ", " ", " ", "│" },
    input = { "├", "─", "┤", "│", "┘", "─", "└", "│" },
}

---@param prompt_text string
---@param opts { layout?: GlimpseLayoutOpts, parser?: function }
---@return GlimpseUI
function M.new(prompt_text, opts)
    ensure_highlights()

    local self = setmetatable({}, UI)
    self.base_prompt = prompt_text
    self.ns_id = vim.api.nvim_create_namespace("glimpse")
    self.prompt_ns = vim.api.nvim_create_namespace("glimpse_prompt")
    self.preview_ns = vim.api.nvim_create_namespace("glimpse_preview")
    self.layout_opts = vim.tbl_extend("force", default_layout, opts.layout or {})
    self.parser = opts.parser

    return self
end

---@return { preview: { width: integer, height: integer, col: integer, row: integer }, results: { width: integer, height: integer, col: integer, row: integer }, input: { width: integer, height: integer, col: integer, row: integer } }
function UI:_calculate_layout()
    local screen_width = vim.o.columns
    local screen_height = vim.o.lines - vim.o.cmdheight - 1

    local width = self.layout_opts.width or 0.85
    local height = self.layout_opts.height or 0.85
    local preview_ratio = self.layout_opts.preview_height or 0.4

    ---@type integer
    local total_width = math.floor(screen_width * width)
    ---@type integer
    local total_height = math.floor(screen_height * height)

    ---@type integer
    local col = math.floor((screen_width - total_width) / 2)
    ---@type integer
    local row = math.floor((screen_height - total_height) / 2)

    ---@type integer
    local preview_height = math.floor(total_height * preview_ratio)
    local input_height = 1
    local results_height = total_height - preview_height - input_height - 4

    local preview_row = row
    local results_row = preview_row + preview_height + 1
    local input_row = results_row + results_height

    return {
        preview = {
            width = total_width - 2,
            height = preview_height,
            col = col,
            row = preview_row,
        },
        results = {
            width = total_width - 2,
            height = results_height,
            col = col,
            row = results_row,
        },
        input = {
            width = total_width - 2,
            height = input_height,
            col = col,
            row = input_row,
        },
    }
end

---@param win_id integer
function UI._configure_window(_, win_id)
    vim.wo[win_id].number = false
    vim.wo[win_id].relativenumber = false
    vim.wo[win_id].signcolumn = "no"
    vim.wo[win_id].cursorline = false
    vim.wo[win_id].foldcolumn = "0"
    vim.wo[win_id].spell = false
    vim.wo[win_id].list = false
    vim.wo[win_id].wrap = false
    vim.wo[win_id].scrolloff = 0
    vim.wo[win_id].sidescrolloff = 0
    vim.wo[win_id].fillchars = "eob: "
    vim.wo[win_id].winhighlight = "NormalFloat:GlimpseNormal,FloatBorder:GlimpseBorder,CursorLine:GlimpseCursorLine"
end

---@return integer input_buf, integer input_win
function UI:create_windows()
    local layout = self:_calculate_layout()

    self.preview_buf = vim.api.nvim_create_buf(false, true)
    self.results_buf = vim.api.nvim_create_buf(false, true)
    self.input_buf = vim.api.nvim_create_buf(false, true)

    vim.bo[self.preview_buf].buftype = "nofile"
    vim.bo[self.preview_buf].bufhidden = "wipe"
    vim.bo[self.results_buf].filetype = "glimpse_results"
    vim.bo[self.input_buf].filetype = "glimpse_input"

    vim.api.nvim_buf_set_lines(self.input_buf, 0, -1, false, { "" })

    local preview_win = vim.api.nvim_open_win(self.preview_buf, false, {
        relative = "editor",
        width = layout.preview.width,
        height = layout.preview.height,
        col = layout.preview.col,
        row = layout.preview.row,
        style = "minimal",
        border = borders.preview,
        zindex = 50,
        title = " " .. self.base_prompt:gsub(">%s*$", "") .. " ",
        title_pos = "center",
    })
    self.preview_win = preview_win

    local results_win = vim.api.nvim_open_win(self.results_buf, false, {
        relative = "editor",
        width = layout.results.width,
        height = layout.results.height,
        col = layout.results.col,
        row = layout.results.row,
        style = "minimal",
        border = borders.results,
        zindex = 50,
    })
    self.results_win = results_win

    local input_win = vim.api.nvim_open_win(self.input_buf, true, {
        relative = "editor",
        width = layout.input.width,
        height = 1,
        col = layout.input.col,
        row = layout.input.row,
        style = "minimal",
        border = borders.input,
        zindex = 50,
    })
    self.input_win = input_win

    self:_configure_window(preview_win)
    self:_configure_window(results_win)
    self:_configure_window(input_win)

    vim.wo[preview_win].number = true
    vim.wo[results_win].cursorline = true

    self.augroup = vim.api.nvim_create_augroup("GlimpseUIResize", { clear = true })
    vim.api.nvim_create_autocmd("VimResized", {
        group = self.augroup,
        callback = function()
            self:_update_layout()
        end,
    })

    local input_buf = self.input_buf

    assert(type(input_buf) == "number" and type(input_win) == "number", "failed to create Glimpse windows")

    ---@cast input_buf integer
    ---@cast input_win integer

    return input_buf, input_win
end

function UI:_update_layout()
    local input_win = self.input_win

    if type(input_win) ~= "number" or not vim.api.nvim_win_is_valid(input_win) then
        return
    end

    local layout = self:_calculate_layout()

    local preview_win = self.preview_win
    if preview_win ~= nil then
        if vim.api.nvim_win_is_valid(preview_win) then
            vim.api.nvim_win_set_config(preview_win, {
                relative = "editor",
                width = layout.preview.width,
                height = layout.preview.height,
                col = layout.preview.col,
                row = layout.preview.row,
                border = borders.preview,
            })
        end
    end

    local results_win = self.results_win
    if results_win ~= nil then
        if vim.api.nvim_win_is_valid(results_win) then
            vim.api.nvim_win_set_config(results_win, {
                relative = "editor",
                width = layout.results.width,
                height = layout.results.height,
                col = layout.results.col,
                row = layout.results.row,
                border = borders.results,
            })
        end
    end

    vim.api.nvim_win_set_config(input_win, {
        relative = "editor",
        width = layout.input.width,
        height = 1,
        col = layout.input.col,
        row = layout.input.row,
        border = borders.input,
    })
end

---@param count_str string
function UI:update_count_display(count_str)
    local input_buf = self.input_buf

    if input_buf ~= nil then
        if not vim.api.nvim_buf_is_valid(input_buf) then
            return
        end

        vim.api.nvim_buf_clear_namespace(input_buf, self.prompt_ns, 0, -1)

        local chevron = defaults and defaults.icons and defaults.icons.separators and defaults.icons.separators.chevron
        local prompt_icon = (chevron and chevron.right or ">") .. " "
        vim.api.nvim_buf_set_extmark(input_buf, self.prompt_ns, 0, 0, {
            virt_text = { { prompt_icon, "GlimpsePrompt" } },
            virt_text_pos = "inline",
            right_gravity = false,
        })

        vim.api.nvim_buf_set_extmark(input_buf, self.prompt_ns, 0, 0, {
            virt_text = { { count_str, "GlimpseCounter" } },
            virt_text_pos = "right_align",
        })
        return
    end
end

function UI:_clear_preview()
    if not self.preview_buf then
        return
    end

    vim.bo[self.preview_buf].modifiable = true
    vim.api.nvim_buf_set_lines(self.preview_buf, 0, -1, false, { "" })
    vim.bo[self.preview_buf].modifiable = false
    self.current_preview_file = nil
end

---@param selection? string
function UI:show_preview(selection)
    local preview_win = self.preview_win

    if preview_win == nil or not vim.api.nvim_win_is_valid(preview_win) then
        return
    end

    local preview_buf = self.preview_buf

    if preview_buf == nil or not vim.api.nvim_buf_is_valid(preview_buf) then
        return
    end

    if not selection or not self.parser then
        self:_clear_preview()

        return
    end

    local data = self.parser(selection)

    if not data or not data.filename then
        self:_clear_preview()

        return
    end

    local filename = data.filename
    ---@type integer
    local lnum = data.lnum or 1
    ---@type integer
    local col = data.col or 1

    if self.current_preview_file ~= filename then
        self.current_preview_file = filename

        if nvim.file.is_binary(filename) then
            vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, { "[Binary File - Preview Disabled]" })
        else
            local content = nvim.file.read(filename)
            local lines

            if content then
                lines = vim.split(content, "\n", { plain = true })
                if #lines > 1000 then
                    lines = vim.list_slice(lines, 1, 1000)
                end
            else
                lines = { "File not found: " .. filename }
            end

            vim.bo[preview_buf].modifiable = true
            vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
            vim.bo[preview_buf].modifiable = false

            local ft = vim.filetype.match({ filename = filename })

            if ft then
                vim.bo[preview_buf].filetype = ft
            end
        end
    end

    local line_count = vim.api.nvim_buf_line_count(preview_buf)
    if lnum > 0 and lnum <= line_count then
        ---@type integer
        local cursor_col = math.max(0, col - 1)
        vim.api.nvim_win_set_cursor(preview_win, { lnum, cursor_col })

        vim.api.nvim_win_call(preview_win, function()
            vim.cmd("normal! zz")
        end)

        vim.api.nvim_buf_clear_namespace(preview_buf, self.preview_ns, 0, -1)
        vim.api.nvim_buf_set_extmark(preview_buf, self.preview_ns, lnum - 1, 0, {
            end_row = lnum - 1,
            end_col = #(vim.api.nvim_buf_get_lines(preview_buf, lnum - 1, lnum, false)[1] or ""),
            hl_group = "Visual",
            priority = 100,
        })
    end
end

---@param matches string[]
---@param selected_index integer
---@param marked table<string, boolean>|nil
---@param query string|nil
function UI:render(matches, selected_index, marked, query)
    if not self.results_buf then
        return
    end

    local total = #matches
    local current = selected_index

    local count_str
    if total > 0 then
        count_str = string.format("%d/%d", current, total)
    else
        count_str = "0/0"
    end

    self:update_count_display(count_str)

    if total == 0 then
        vim.api.nvim_buf_set_lines(self.results_buf, 0, -1, false, { "" })
        self:show_preview(nil)

        return
    end

    vim.api.nvim_buf_set_lines(self.results_buf, 0, -1, false, matches)
    vim.api.nvim_buf_clear_namespace(self.results_buf, self.ns_id, 0, -1)

    for i, line in ipairs(matches) do
        ---@type integer
        local line_idx = i - 1
        highlight.highlight_entry(self.results_buf, self.ns_id, line_idx, line, i <= 200)
        highlight.highlight_matches(self.results_buf, self.ns_id, line_idx, line, query or "")

        if marked and marked[line] then
            vim.api.nvim_buf_set_extmark(self.results_buf, self.ns_id, line_idx, 0, {
                sign_text = "●",
                sign_hl_group = "String",
                priority = 105,
            })
        end
    end

    if selected_index > 0 and selected_index <= total then
        local selected_text = matches[selected_index]

        local results_win = self.results_win

        if results_win ~= nil then
            if vim.api.nvim_win_is_valid(results_win) then
                vim.api.nvim_win_set_cursor(results_win, { selected_index, 0 })
            end
        end

        self:show_preview(selected_text)
    end
end

---@param text string
function UI:set_prompt(text)
    self.base_prompt = text
    local preview_win = self.preview_win

    if preview_win ~= nil then
        if vim.api.nvim_win_is_valid(preview_win) then
            vim.api.nvim_win_set_config(preview_win, {
                title = " " .. text:gsub(">%s*$", "") .. " ",
                title_pos = "center",
            })
        end
    end
end

---@param lines string[]
function UI:update_input(lines)
    local input_buf = self.input_buf
    local input_win = self.input_win

    if type(input_buf) ~= "number" or type(input_win) ~= "number" then
        return
    end

    vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(input_win, { 1, #lines[1] })
end

---@param win integer?
local function close_win(win)
    if win == nil then
        return
    end

    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
end

function UI:close()
    if self.augroup then
        vim.api.nvim_del_augroup_by_id(self.augroup)
        self.augroup = nil
    end

    close_win(self.preview_win)
    close_win(self.results_win)
    close_win(self.input_win)

    vim.cmd("stopinsert")
end

return M
