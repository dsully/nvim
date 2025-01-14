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

M.notifications = function()
    local fzf = require("fzf-lua")

    ---@type snacks.notifier.Notif[]
    local entries = Snacks.notifier.get_history({ reverse = true })

    if #entries == 0 then
        notify.info("No notifications.", { title = "Notification history", icon = "󰎟" })
        return
    end

    ---@param str string
    ---@return string
    local function cap(str)
        return str:sub(1, 1):upper() .. str:sub(2):lower()
    end

    ---@param name string
    ---@param level? snacks.notifier.level
    ---@return string
    local function hl(name, level)
        return "SnacksNotifier" .. name .. (level and cap(level) or "")
    end

    ---@param entry string
    ---@return snacks.notifier.Notif?
    local find_entry = function(entry)
        return entries[tonumber(entry:match("^%s*(%d+)") or "0")]
    end

    local builtin = require("fzf-lua.previewer.builtin")
    local previewer = builtin.buffer_or_file:extend()

    function previewer:new(o, fzf_opts, fzf_win)
        previewer.super.new(self, o, fzf_opts, fzf_win)
        self.title = "Notifications"
        setmetatable(self, previewer)
        return self
    end

    ---@param entry_str string
    ---@return snacks.notifier.Notif?
    function previewer:parse_entry(entry_str)
        return find_entry(entry_str)
    end

    ---@param selected string
    function previewer:populate_preview_buf(selected)
        local buf = self:get_tmp_buffer()

        local notification = find_entry(selected)

        if notification ~= nil then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(notification.msg, "\n", { plain = true }))
            vim.bo[buf].filetype = notification.ft or "lua"
        end

        self:set_preview_buf(buf)
    end

    -- Disable line numbering and word wrap
    function previewer:gen_winopts()
        return vim.tbl_extend("force", self.winopts, {
            cursorline = false,
            number = false,
            wrap = true,
        })
    end

    ---@type string[]
    local contents = {}

    for e, entry in ipairs(entries) do
        --
        ---@type string[]
        local display = { string.format("%2d: ", e) }

        for _, t in ipairs({
            { tostring(os.date("%R", entry.added)), hl("HistoryDateTime") },
            { " ", "Normal" },
            { entry.icon, hl("Icon", entry.level) },
            { " ", "Normal" },
            { entry.msg, "Normal" },
        }) do
            display[#display + 1] = t[2] and fzf.utils.ansi_from_hl(t[2], t[1]) or t[1]
        end

        contents[#contents + 1] = table.concat(display)
    end

    fzf.fzf_exec(contents, {
        previewer = previewer,
        actions = {
            ---@param selected string
            ["default"] = function(selected)
                local entry = find_entry(selected)

                if entry then
                    vim.fn.setreg("+", entry.msg)
                end
            end,
        },
    })
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
