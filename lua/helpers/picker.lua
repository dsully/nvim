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
    opts.cwd = opts.cwd or vim.uv.cwd()

    local parent_directories = {}
    local cwd = opts.cwd

    while cwd ~= "/" do
        table.insert(parent_directories, cwd)
        cwd = vim.fs.dirname(cwd)
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
---@field contents string[]
---@field preview string
---@field data snacks.notifier.Notif

M.notifications = function()
    local fzf = require("fzf-lua")

    local white = fzf.utils.ansi_codes.white
    local strip = fzf.utils.strip_ansi_coloring

    ---@type table<integer, snacks.notifier.Notif>
    local mapping = {}

    ---@param notification snacks.notifier.Notif
    ---@type Notification[]
    local notifications = vim.tbl_map(function(notification)
        local icon_color = notification.level == "error" and "red" or notification.level == "warn" and "yellow" or "green"

        local icon = fzf.utils.ansi_codes[icon_color](notification.icon)
        local level = fzf.utils.ansi_codes[icon_color](notification.level)
        local timestamp = white(tostring(os.date("%R", notification.added)))
        local title = notification.title ~= "" and notification.title or "[No title]"
        local prefix = table.concat({ timestamp, icon, level:upper(), title }, " ")

        mapping[strip(prefix)] = notification

        return {
            contents = { prefix },
            preview = notification.msg,
            data = notification,
        }
    end, Snacks.notifier.get_history({ reverse = true }))

    if #notifications == 0 then
        notify.info("No notifications.", { title = "Notification history", icon = "󰎟" })
        return
    end

    function M.previewer()
        local previewer = require("fzf-lua.previewer.builtin").base:extend()

        function previewer:new(o, opts, fzf_win)
            previewer.super.new(self, o, opts, fzf_win)
            self.title = "Notifications"
            setmetatable(self, previewer)
            return self
        end

        ---@param selected string
        function previewer:populate_preview_buf(selected)
            local buf = self:get_tmp_buffer()
            local notification = mapping[strip(selected)]

            if notification ~= nil then
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(notification.msg, "\n", { plain = true }))
                vim.bo[buf].filetype = "lua"
            end

            self:set_preview_buf(buf)
            self.win:update_title(" Notifications ")
            self.win:update_scrollbar()
        end

        -- Disable line numbering and word wrap
        function previewer:gen_winopts()
            local new_winopts = {
                cursorline = false,
                number = false,
                wrap = true,
            }

            return vim.tbl_extend("force", self.winopts, new_winopts)
        end

        return previewer
    end

    fzf.fzf_exec(notifications, {
        previewer = M.previewer(),
        actions = {
            ["default"] = function(selected)
                local id = strip(selected[1])
                local entry = mapping[id]

                if entry ~= nil then
                    vim.fn.setreg("+", entry.msg)
                end
            end,
        },
    })
end

---@param command string
---@param cwd function|string|nil
---@param opts table<string, any>?
M.pick = function(command, cwd, opts)
    return function()
        --
        if type(cwd) == "function" then
            cwd = cwd()
        end

        pcall(require("fzf-lua")[command], vim.tbl_deep_extend("force", opts or {}, { cwd = cwd }))
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
