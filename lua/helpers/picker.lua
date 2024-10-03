local M = {}

local EXCLUDED_DIRS_FD = table.concat(
    vim.tbl_map(function(dir)
        return "--exclude " .. dir
    end, {
        ".git",
        ".Trash",
        "iCloud",
        "Library",
        "Movies",
        "Pictures",
        "node_modules",
        "target",
        "vendor",
    }),
    " "
)

M.fd = function(opts, callback, fallback)
    opts = opts or {}
    opts.cwd = opts.cwd or vim.uv.cwd()
    opts.prompt = opts.prompt or "Directories > "

    opts.cmd = opts.cmd
        or table.concat({
            "fd",
            "-t d",
            "-d 5",
            "--hidden",
            "--one-file-system",
            "--base-directory " .. opts.cwd,
            EXCLUDED_DIRS_FD,
        }, " ")

    opts.actions = {
        ["default"] = function(selected)
            if selected[1] == nil then
                return
            end

            vim.cmd.cd(vim.fn.expand(opts.cwd .. "/" .. selected[1]))

            callback(opts)
        end,
        ["esc"] = function()
            if fallback then
                fallback(opts)
            end
        end,
    }

    require("fzf-lua").fzf_exec(opts.cmd, opts)
end

M.repositories = function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd or vim.fn.expand("~/dev")
    opts.prompt = opts.prompt or "Git repos > "

    opts.cmd = table.concat({
        "fd",
        "-t d",
        "--one-file-system",
        "--hidden",
        "--base-directory " .. opts.cwd,
        "^.git$",
        "-x dirname {} \\;",
    }, " ")

    local function callback()
        M.subdirectory({}, require("fzf-lua").files)
    end

    M.fd(opts, callback)
end

M.subdirectory = function(opts, fallback)
    M.fd(opts or {}, require("fzf-lua").files, fallback)
end

M.parents = function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd or vim.fn.getcwd()

    local parent_directories = {}
    local cwd = opts.cwd

    while cwd ~= "/" do
        table.insert(parent_directories, cwd)
        cwd = vim.fn.fnamemodify(cwd, ":h")
    end

    opts.actions = {
        ["default"] = function(selected)
            -- Full path so it doesn't need to be expanded
            vim.cmd.cd(selected[1])

            -- Fallback
            M.subdirectory({}, require("fzf-lua").files)
        end,
    }

    require("fzf-lua").fzf_exec(parent_directories, opts)
end

---@class Notification
---@field display string
---@field ordinal string
---@field preview string
---@field data notify.Record

M.notifications = function()
    local fzf = require("fzf-lua")
    local notify = require("notify")

    ---@type table<integer, notify.Record>
    local id_mapping = {}

    ---@param notification notify.Record
    ---@type Notification[]
    local notifications = vim.tbl_map(function(notification)
        local icon_color = notification.level == "ERROR" and "red" or notification.level == "WARN" and "yellow" or "green"

        local icon = fzf.utils.ansi_codes[icon_color](notification.icon)
        local level = fzf.utils.ansi_codes[icon_color](notification.level)
        local timestamp = fzf.utils.ansi_codes.grey(notification.title[2])
        local title = notification.title[1] ~= "" and notification.title[1] or "[No title]"
        local prefix = table.concat({ timestamp, icon, level, title }, " ")
        local id = notification.id

        id_mapping[id] = notification

        return {
            contents = { id .. ": " .. prefix },
            preview = notification.message,
            data = notification,
        }
    end, notify.history())

    table.sort(notifications, function(a, b)
        return a.data.time > b.data.time
    end)

    ---@param _messages table<number, Notification>
    function M.previewer(_messages)
        local previewer = require("fzf-lua.previewer.builtin").base:extend()

        function previewer:new(o, opts, fzf_win)
            previewer.super.new(self, o, opts, fzf_win)
            self.title = "Notifications"
            setmetatable(self, previewer)
            return self
        end

        ---@param entry string
        ---@return notify.Record?
        function previewer:parse_entry(entry)
            --
            ---@type number?
            local id = tonumber(entry:match("^%d+"))

            return id_mapping[id]
        end

        ---@param entry string
        function previewer:populate_preview_buf(entry)
            local buf = self:get_tmp_buffer()
            local notification = self:parse_entry(entry)

            if notification ~= nil then
                require("notify").open(notification, { buffer = buf, max_width = 80 })
            end

            self:set_preview_buf(buf)
            self.win:update_title(" Notifications ")
            self.win:update_scrollbar()
        end

        return previewer
    end

    fzf.fzf_exec(notifications, {
        previewer = M.previewer(notifications),
        actions = {
            ["default"] = function(selected)
                local id = tonumber(selected[1]:match("^%d+"))
                local entry = id_mapping[id]

                vim.fn.setreg("+", table.concat(entry.message, "\n"))
            end,
        },
    })
end

---@param command string
---@param cwd function|string|nil
M.pick = function(command, cwd)
    return function()
        --
        if type(cwd) == "function" then
            cwd = cwd()
        end

        pcall(require("fzf-lua")[command], { cwd = cwd })
    end
end

-- Grep the current buffer for the cword.
-- Match on partial words.
M.grep_curbuf_cword = function(opts)
    local config = require("fzf-lua.config")

    opts = opts or {}
    opts.filename = require("fzf-lua.path").relative_to(vim.api.nvim_buf_get_name(0), tostring(vim.uv.cwd()))
    opts.no_esc = true
    opts.exec_empty_query = false
    opts.fzf_opts = config.globals.blines.fzf_opts

    opts.search = require("fzf-lua.utils").rg_escape(vim.fn.expand("<cword>"))

    require("fzf-lua").grep(config.normalize_opts(opts, "grep", "bgrep"))
end

return M
