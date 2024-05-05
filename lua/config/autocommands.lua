local e = require("helpers.event")

e.on({ e.FocusGained, e.TermClose, e.TermLeave }, function()
    vim.cmd.checktime()
end, {
    desc = "Check if we need to reload the file when it changed.",
})

e.on({ e.BufEnter, e.FileType }, function(event)
    vim.opt_local.spell = false

    pcall(vim.api.nvim_buf_set_name, event.buf, event.match)

    vim.keymap.set("n", "q", function()
        vim.cmd.BWipeout()
        vim.cmd.close({ mods = { emsg_silent = true, silent = true } })
    end, { noremap = true, silent = true, buffer = event.buf })
end, {
    desc = "Map q to close the buffer.",
    pattern = { "checkhealth", "codecompanion", "man", "nofile", "notify", "qf", "tsplayground" },
})

e.on(e.BufWinEnter, function(event)
    --
    -- Don't try to close a help buffer if explicitly edited.
    if #vim.api.nvim_list_bufs() == 1 then
        return
    end

    local filetype = vim.bo[event.buf].filetype
    local file_path = event.match

    if file_path:match("/doc/") ~= nil then
        --
        if filetype == "help" or filetype == "markdown" then
            local help_win = vim.api.nvim_get_current_win()

            require("helpers.float").open({
                anchor = "E",
                filetype = filetype,
                lines = vim.api.nvim_buf_get_lines(event.buf, 0, -1, false),
            })

            -- Close the initial help split window.
            vim.api.nvim_win_close(help_win, false)
        end
    end
end, {
    desc = "Open Help in a floating window.",
})

e.on(e.FileType, function()
    vim.keymap.set("n", "J", function()
        --
        return vim.endswith(vim.api.nvim_get_current_line(), [[\]]) and "$xJ" or "J"
    end, { expr = true, desc = "Remove trailing backslash when joining lines." })
end, {
    desc = "Keymap for removing backslashes when joining lines.",
    pattern = { "bash", "fish", "make", "sh", "zsh" },
})

e.on(e.FileType, function()
    vim.opt_local.formatoptions:remove({ "a", "o", "t" })
    vim.api.nvim_set_option_value("foldenable", false, { scope = "local", win = 0 })
end, {
    desc = "Update format options and folding.",
})

-- e.on(e.BufHidden, function(event)
--     if event.file == "" and vim.bo[event.buf].buftype == "" and not vim.bo[event.buf].modified then
--         vim.schedule(function()
--             pcall(vim.api.nvim_buf_delete, event.buf, {})
--         end)
--     end
-- end, {
--     desc = "Delete [No Name] buffers",
-- })

e.on(e.BufReadCmd, function(args)
    vim.cmd.bdelete({ args.buf, bang = true })
    vim.cmd.edit(vim.uri_to_fname(args.file))
end, {
    nested = true,
    pattern = "file:///*",
})

-- Replace with:
-- { "lewis6991/fileline.nvim", enable = false, lazy = false }
--
-- If the multi-file bug is addressed.
--
e.on(e.BufNewFile, function(args)
    -- Trailing colon, i.e. ':lnum[:colnum[:]]'
    local pattern = "^([^:]+):(%d*:?%d*):?$"

    local path, capture = vim.api.nvim_buf_get_name(args.buf):match(pattern)

    path = vim.fn.fnameescape(path)

    if capture and path and vim.uv.fs_access(path, "R") then
        --
        vim.cmd.edit({ path, mods = { keepalt = true } })

        vim.api.nvim_buf_delete(args.buf, {})

        local pos = vim.tbl_map(tonumber, vim.split(capture, ":", { trimempty = true }))

        -- If the file was opened with '/path/to/filename:' we won't have a position.
        if not vim.tbl_isempty(pos) then
            vim.api.nvim_win_set_cursor(0, {
                math.min(math.max(1, pos[1]), vim.api.nvim_buf_line_count(0)),
                pos[2] and pos[2] - 1 or 0,
            })
        end

        vim.cmd.normal({ "zz", bang = true })
        vim.cmd.filetype("detect")
    end

    return path
end, {
    nested = true,
})

-- e.on({ e.BufReadCmd }, {
--     callback = function(args)
--         -- This must be called for LSP and other events to work.
--         vim.cmd.doautocmd("BufReadPre")
--
--         -- Trailing colon, i.e. ':lnum[:colnum[:]]'
--         local pattern = ":(%d*:?%d*):?$"
--
--         local cwd = (vim.uv.cwd() or vim.fn.getcwd()) .. "/"
--
--         -- Strip off any duplicated parent path.
--         local bufname = vim.api.nvim_buf_get_name(args.buf):gsub(cwd, "")
--         local capture = bufname:match(pattern)
--         local pos = nil
--         local fqfn = nil
--         local numeric = false
--
--         -- Skip filenames that are all numbers.
--         if bufname:match("^%d$") then
--             numeric = true
--         end
--
--         -- If the next argument is a +<line>
--         for i, v in ipairs(vim.v.argv) do
--             if v == bufname then
--                 --
--                 -- If the next argument is a +<line>
--                 if vim.v.argv[i + 1] ~= nil and vim.v.argv[i + 1]:match("^+%d+") then
--                     pos = { tonumber(vim.v.argv[i + 1]:gsub("%+", "") or 0), 0 }
--                 end
--             end
--         end
--
--         if capture and capture ~= "" and not numeric and not pos then
--             -- Allow for /path/to/file:<row>:
--             pos = vim.split(capture, ":", {})
--             pos = { tonumber(pos[1]) or 1, tonumber(pos[2] or 0) or 0 }
--         elseif pos == nil and not vim.endswith(bufname, ".plist") then
--             -- If the position wasn't set via the filename, check previous marks.
--             pos = vim.api.nvim_buf_get_mark(0, '"')
--         end
--
--         local path = numeric and bufname or bufname:gsub(pattern, "")
--
--         -- Look for non-qualified paths that aren't cwd local.
--         if not bufname:match("^[/~]") and bufname:find("/") then
--             --
--             -- A partial path almost always comes from git.
--             -- Find the root, then strip off the parent path.
--             local root = vim.system({ "git", "rev-parse", "--show-toplevel" }, { cwd = cwd, text = true }):wait().stdout
--
--             fqfn = vim.trim(root or cwd) .. "/" .. path
--
--             if vim.uv.fs_stat(fqfn) then
--                 path = fqfn
--             end
--         end
--
--         if pos ~= nil or fqfn ~= nil and vim.uv.fs_stat(path) then
--             pcall(vim.cmd.file, path)
--             pcall(vim.cmd.edit, { bang = true })
--
--             -- Make sure we don't try and set marks on a file that already has marks,
--             -- but has changed out from underneath us.
--             local count = vim.api.nvim_buf_line_count(args.buf)
--
--             if pos and count >= pos[1] then
--                 vim.api.nvim_buf_set_mark(args.buf, '"', pos[1], pos[2], {})
--             end
--         end
--
--         vim.cmd.doautocmd("BufReadPost")
--     end,
-- })

e.on(e.BufReadPost, function(args)
    local buf = args.buf

    if vim.tbl_contains(require("config.defaults").ignored.file_types, vim.bo[buf].filetype) then
        vim.notify("Skipping position restore for: " .. vim.bo[buf].filetype, vim.log.levels.WARN)
        return
    end

    -- Skip restoring if we're in a session restore already.
    if vim.b[buf].resession_restore_last_pos then
        return
    end

    local row, col = unpack(vim.api.nvim_buf_get_mark(buf, '"'))

    if row > 0 and row <= vim.api.nvim_buf_line_count(buf) then
        vim.api.nvim_win_set_cursor(0, { row, col })
    end

    vim.cmd.normal({ "zz", bang = true })
end, {
    desc = "Restore cursor to the last known position.",
})

e.on({ e.BufReadPost, e.FileReadPost }, function()
    if vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]:sub(-1) == "\r" then
        vim.cmd(":edit ++ff=dos")
    end
end, {
    desc = "Hide Windows line endings.",
})

e.on({ e.BufReadPost, e.FileReadPost }, function(args)
    local stat = vim.uv.fs_stat(args.file)

    if not stat or stat.size < vim.g.large_file_size then
        return
    end

    vim.g.large_file = true

    vim.notify("File is too large, disabling treesitter, syntax & language servers.")

    for _, client in pairs(vim.lsp.get_clients({ bufnr = args.buf })) do
        pcall(vim.lsp.buf_detach_client, args.buf, client.id)
    end

    -- Create a autocommand just in case.
    e.on(e.LspAttach, function(a)
        vim.lsp.buf_detach_client(args.buf, a.data.client_id)
    end, {
        buffer = args.buf,
    })

    vim.diagnostic.enable(false)

    -- Disable indentline
    vim.b.miniindentscope_disable = true

    vim.cmd.TSDisable("highlight")
    vim.cmd.TSDisable("incremental_selection")
    vim.cmd.TSDisable("indent")
    vim.cmd.syntax("off")

    vim.bo.swapfile = false
    vim.bo.undolevels = -1

    vim.api.nvim_set_option_value("foldmethod", "manual", { scope = "local", win = 0 })
    vim.api.nvim_set_option_value("list", false, { scope = "local", win = 0 })
    vim.api.nvim_set_option_value("spell", false, { scope = "local", win = 0 })

    vim.opt.undoreload = 0
end, {
    desc = "Disable features for large files.",
})

e.on(e.FileType, function()
    --
    e.on(e.BufWritePre, function()
        local shebang = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]

        if not shebang or not shebang:match("^#!.+") then
            return
        end

        e.on(e.BufWritePost, function(args)
            local filename = vim.api.nvim_buf_get_name(args.buf)

            local fileinfo = vim.uv.fs_stat(filename)

            if not fileinfo or bit.band(fileinfo.mode - 32768, 0x40) ~= 0 then
                return
            end

            vim.uv.fs_chmod(filename, bit.bor(fileinfo.mode, 493))
        end, { once = true })
    end)
end, {
    desc = "Mark script files with shebangs as executable on write.",
    pattern = { "bash", "python", "sh", "zsh" },
})

e.on(e.BufWritePre, function()
    vim.opt_local.undofile = false
end, {
    desc = "Disable the undo file for temporary files.",
    pattern = { "COMMIT_EDITMSG", "MERGE_MSG", "gitcommit", "*.tmp", "*.log" },
})

e.on(e.BufWritePre, function(args)
    local path = vim.fs.dirname(args.file)

    if path and not vim.uv.fs_stat(path) then
        vim.uv.fs_mkdir(path, 511)
    end
end, {
    desc = "Create parent directories before write.",
})

e.on(e.BufWriteCmd, function()
    vim.opt_local.modified = false
end, {
    desc = "Don't let me write out a file named ';'",
    pattern = ";",
})

e.on(e.BufWritePost, function(args)
    --- @type string
    local file = args.file

    file = file:gsub(".-/chezmoi%-edit%d+", vim.env.HOME)
    file = file:gsub("dot_", ".")
    file = file:gsub("private_", "")
    file = file:gsub(".tmpl", "")

    vim.notify("chezmoi: Applying changes to: " .. file, vim.log.DEBUG)

    vim.system({ "chezmoi", "apply", "--no-tty", "--exclude", "scripts", file }):wait()
end, {
    desc = "Apply chezmoi changes via 'chezmoi edit'",
    pattern = "*/chezmoi-edit*",
})

e.on(e.TextYankPost, function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 500 })

    -- Copy data to system clipboard only when we are pressing 'y'. 'd', 'x' will be filtered out.
    if vim.v.operator ~= "y" then
        return
    end

    local copy = function(str)
        local ok, error = pcall(vim.fn.setreg, "+", str)

        if not ok then
            vim.notify("Failed to copy to clipboard: " .. error, vim.log.levels.ERROR)
            return
        end
    end

    local present, yank_data = pcall(vim.fn.getreg, '"')

    if not present then
        vim.notify('Failed to get content from register ": ' .. yank_data, vim.log.levels.ERROR)
        return
    end

    if #yank_data < 1 then
        return
    end

    copy(yank_data)
end, {
    desc = "Copy and highlight yanked text to system clipboard",
    group = vim.api.nvim_create_augroup("SmartYank", { clear = true }),
})
