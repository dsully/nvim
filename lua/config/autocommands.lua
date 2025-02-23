ev.on({ ev.FocusGained, ev.TermClose, ev.TermLeave }, function()
    if vim.o.buftype ~= defaults.ignored.buffer_types then
        vim.cmd.checktime()
    end
end, {
    desc = "Check if we need to reload the file when it changed.",
})

ev.on(ev.BufEnter, function(event)
    if vim.fn.winnr("$") == 1 and vim.bo.buftype == "quickfix" then
        Snacks.bufdelete({ buf = event.buf, force = true } --[[@as snacks.bufdelete.Opts]])
    end
end, {
    desc = "Close quick fix window if the file containing it was closed.",
})

ev.on(ev.QuitPre, function()
    if vim.bo.filetype ~= "qf" then
        vim.cmd.lclose({ mods = { silent = true } })
    end
end, {
    desc = "Automatically close corresponding loclist when quitting a window.",
    nested = true,
})

ev.on(ev.FileType, function()
    keys.map("J", function()
        --
        return vim.endswith(vim.api.nvim_get_current_line(), [[\]]) and "$xJ" or "J"
    end, "Remove trailing backslash when joining lines.", "n", { expr = true })
end, {
    desc = "Keymap for removing backslashes when joining lines.",
    pattern = {
        "bash",
        "fish",
        "make",
        "sh",
        "zsh",
    },
})

ev.on(ev.FileType, function(event)
    vim.opt.formatoptions = {
        c = true, -- Auto-wrap comments using 'textwidth', inserting the current comment leader automatically.
        j = true, -- Where it makes sense, remove a comment leader when joining lines.
        l = true, -- Long lines are not broken in insert mode.
        n = true, -- When formatting text, recognize numbered lists.
        q = true, -- Allow formatting of comments with "gq".
    }

    vim.api.nvim_set_option_value("foldenable", false, { scope = "local", win = 0 })

    if pcall(vim.treesitter.start, event.buf) then
        ev.emit(ev.User, { pattern = "ts_attach" })
    end
end, {
    desc = "Update format options and folding.",
})

ev.on(ev.BufReadCmd, function(args)
    vim.cmd.bdelete({ args.buf, bang = true })
    vim.cmd.edit(vim.uri_to_fname(args.file))
end, {
    desc = "Allow opening of file:/// URLs as a file.",
    nested = true,
    pattern = "file:///*",
})

ev.on(ev.BufWinEnter, function(args)
    if vim.tbl_contains(defaults.ignored.file_types, vim.bo.filetype) then
        return
    end

    local row, col = unpack(vim.api.nvim_buf_get_mark(args.buf, '"'))
    local count = vim.api.nvim_buf_line_count(args.buf)

    if row and row > 0 and row <= count then
        vim.api.nvim_win_set_cursor(0, { row, col })

        -- If we're in the middle of the file, set the cursor position and center the screen
        if count - row > ((vim.fn.line("w$") - vim.fn.line("w0")) / 2) - 1 then
            vim.cmd.normal({ "zz", bang = true })

        -- If we're at the end of the screen, set the cursor position and move the window up by one with C-e.
        -- This is to show that we are at the end of the file. If we did "zz" half the screen would be blank.
        elseif count ~= vim.fn.line("w$") then
            keys.feed("<C-e>", "n")
        end
    end
end, {
    desc = "Restore cursor to the last known position.",
})

ev.on({ ev.BufReadPost, ev.FileReadPost }, function()
    if vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]:sub(-1) == "\r" then
        vim.cmd(":edit ++ff=dos")
    end
end, {
    desc = "Hide Windows line endings.",
})

ev.on(ev.FileType, function()
    --
    ev.on(ev.BufWritePre, function()
        local shebang = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]

        if not shebang or not shebang:match("^#!.+") then
            return
        end

        ev.on(ev.BufWritePost, function(args)
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
    pattern = {
        "bash",
        "fish",
        "python",
        "sh",
        "zsh",
    },
})

ev.on(ev.BufWritePre, function()
    vim.opt_local.undofile = false
end, {
    desc = "Disable the undo file for temporary files.",
    pattern = {
        "COMMIT_EDITMSG",
        "MERGE_MSG",
        "gitcommit",
        "*.tmp",
        "*.log",
    },
})

ev.on(ev.BufWritePre, function(args)
    pcall(vim.uv.fs_mkdir, vim.fs.dirname(args.file), 511)
end, {
    desc = "Create parent directories before write.",
})

ev.on(ev.BufWriteCmd, function()
    vim.opt_local.modified = false
end, {
    desc = "Don't let me write out a file named ';'",
    pattern = ";",
})

ev.on(ev.TextYankPost, function()
    -- vim.hl.on_yank({ higroup = "Visual", timeout = 500 })

    -- Copy data to system clipboard only when we are pressing 'y'. 'd', 'x' will be filtered out.
    if vim.v.operator ~= "y" then
        return
    end

    local copy = function(str)
        local ok, error = pcall(vim.fn.setreg, "+", str)

        if not ok then
            notify.error("Failed to copy to clipboard: " .. error)
            return
        end
    end

    local present, yank_data = pcall(vim.fn.getreg, '"')

    if not present then
        notify.error('Failed to get content from register ": ' .. yank_data)
        return
    end

    if #yank_data < 1 then
        return
    end

    copy(yank_data)
end, {
    desc = "Copy and highlight yanked text to system clipboard",
    group = ev.group("SmartYank", true),
})

return {}
