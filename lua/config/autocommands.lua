ev.on({ ev.FocusGained, ev.TermClose, ev.TermLeave }, function()
    if vim.o.buftype ~= "nofile" then
        vim.cmd.checktime()
    end
end, {
    desc = "Check if we need to reload the file when it changed.",
})

ev.on({ ev.BufEnter, ev.FileType }, function(event)
    --
    keys.bmap("q", function()
        vim.api.nvim_buf_delete(event.buf, { force = true })
        vim.cmd.close({ mods = { emsg_silent = true, silent = true } })
    end, "Close Buffer", event.buf)
end, {
    desc = "Map q to close the buffer.",
    pattern = {
        "checkhealth",
        "grug-far",
        "lspinfo",
        "man",
        "nofile",
        "qf",
        "scratch",
    },
})

ev.on(ev.FileType, function()
    vim.keymap.set("n", "J", function()
        --
        return vim.endswith(vim.api.nvim_get_current_line(), [[\]]) and "$xJ" or "J"
    end, { expr = true, desc = "Remove trailing backslash when joining lines." })
end, {
    desc = "Keymap for removing backslashes when joining lines.",
    pattern = { "bash", "fish", "make", "sh", "zsh" },
})

ev.on(ev.FileType, function()
    vim.opt_local.formatoptions:remove({ "a", "o", "t" })
    vim.api.nvim_set_option_value("foldenable", false, { scope = "local", win = 0 })
end, {
    desc = "Update format options and folding.",
})

ev.on(ev.BufReadCmd, function(args)
    vim.cmd.bdelete({ args.buf, bang = true })
    vim.cmd.edit(vim.uri_to_fname(args.file))
end, {
    nested = true,
    pattern = "file:///*",
})

ev.on(ev.BufWinEnter, function(args)
    if vim.tbl_contains(defaults.ignored.file_types, vim.bo.filetype) then
        return
    end

    local row, col = unpack(vim.api.nvim_buf_get_mark(args.buf, '"'))
    local count = vim.api.nvim_buf_line_count(args.buf)

    if row > 0 and row <= count then
        vim.api.nvim_win_set_cursor(0, { row, col })

        -- If we're in the middle of the file, set the cursor position and center the screen
        if count - row > ((vim.fn.line("w$") - vim.fn.line("w0")) / 2) - 1 then
            vim.cmd.normal({ "zz", bang = true })

        -- If we're at the end of the screen, set the cursor position and move the window up by one with C-e.
        -- This is to show that we are at the end of the file. If we did "zz" half the screen would be blank.
        elseif count ~= vim.fn.line("w$") then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-e>", true, false, true), "n", false)
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
    pattern = { "bash", "python", "sh", "zsh" },
})

ev.on(ev.BufWritePre, function()
    vim.opt_local.undofile = false
end, {
    desc = "Disable the undo file for temporary files.",
    pattern = { "COMMIT_EDITMSG", "MERGE_MSG", "gitcommit", "*.tmp", "*.log" },
})

ev.on(ev.BufWritePre, function(args)
    local path = vim.fs.dirname(args.file)

    if path and not vim.uv.fs_stat(path) then
        vim.uv.fs_mkdir(path, 511)
    end
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
    vim.hl.on_yank({ higroup = "Visual", timeout = 500 })

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
