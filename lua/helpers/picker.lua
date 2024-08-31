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

M.notifications = function()
    local fzf = require("fzf-lua")
    local notify = require("notify")

    ---@param notification notify.Record
    local notifications = vim.tbl_map(function(notification)
        local icon_color = notification.level == "ERROR" and "red" or notification.level == "WARN" and "yellow" or "green"

        local icon = fzf.utils.ansi_codes[icon_color](notification.icon)
        local level = fzf.utils.ansi_codes[icon_color](notification.level)
        local timestamp = fzf.utils.ansi_codes.grey(notification.title[2])
        local title = notification.title[1] ~= "" and notification.title[1] or "[No title]"

        return {
            prefix = table.concat({ timestamp, icon, level, title }, " ") .. " > ",
            contents = notification.message,
            preview = notification.message,
            data = notification,
        }
    end, notify.history())

    table.sort(notifications, function(a, b)
        return a.data.time > b.data.time
    end)

    fzf.fzf_exec(notifications, {
        fzf_opts = {
            ["--delimiter"] = ":",
            ["--with-nth"] = "2..",
        },
        actions = {
            ["alt-q"] = fzf.actions.buf_sel_to_qf,
        },
        previewer = "builtin",
        winopts = {
            title = " Notifications ",
            title_pos = "center",
        },
    })
end

M.pick = function(command)
    return "<cmd>FzfLua " .. command .. "<cr>"
end

M.file = function(cwd)
    return function()
        require("fzf-lua").files({ cwd = cwd })
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
