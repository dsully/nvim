--
require("config.autocommands.plist")

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    command = "checktime",
    desc = "Check if we need to reload the file when it changed.",
})

vim.api.nvim_create_autocmd({ "FileType" }, {
    desc = "Map q to close the buffer.",
    pattern = { "checkhealth", "help", "man", "qf", "tsplayground" },
    callback = function(event)
        vim.opt_local.spell = false

        if event.match == "help" then
            vim.cmd.wincmd({ "T", mods = { silent = true } })
            vim.bo[event.buf].buflisted = true
        else
            vim.api.nvim_buf_set_name(event.buf, event.match)
        end

        -- Don't try to close a help buffer if explicitly edited.
        if #vim.api.nvim_list_bufs() > 1 then
            vim.keymap.set("n", "q", function()
                vim.cmd.BWipeout()
                vim.cmd.close({ mods = { emsg_silent = true, silent = true } })
            end, { noremap = true, silent = true, buffer = event.buf })
        end
    end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufNew", "FileType" }, {
    desc = "Update format options and folding.",
    callback = function()
        vim.opt_local.formatoptions:remove({ "a", "o", "t" })
        vim.api.nvim_set_option_value("foldenable", false, { scope = "local", win = 0 })
    end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    desc = "Hide Windows line endings.",
    callback = function()
        if vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]:sub(-1) == "\r" then
            vim.cmd(":edit ++ff=dos")
        end
    end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    desc = "Disable the undo file for temporary files.",
    pattern = { "COMMIT_EDITMSG", "MERGE_MSG", "gitcommit", "*.tmp", "*.log" },
    callback = function()
        vim.opt_local.undofile = false
    end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    desc = "Create parent directories before write.",
    callback = function(args)
        local path = vim.fs.dirname(args.file)

        if not vim.uv.fs_stat(path) then
            vim.uv.fs_mkdir(path, 511)
        end
    end,
})

vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
    desc = "Don't let me write out a file named ';'",
    pattern = ";",
    callback = function()
        vim.opt_local.modified = false
    end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    callback = function()
        local entries = {}
        local lines = {}

        -- Collect existing entries from the buffer.
        for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, true)) do
            for category, entry in line:gmatch("(%l+) (.+)") do
                if not entries[category] then
                    entries[category] = { entry }
                else
                    table.insert(entries[category], entry)
                end
            end
        end

        for _, category in ipairs({ "tap", "brew", "cask", "mas" }) do
            if entries[category] then
                -- The actual sort.
                table.sort(entries[category])

                for _, item in ipairs(entries[category]) do
                    table.insert(lines, category .. " " .. item)
                end
            end
        end

        vim.api.nvim_buf_set_lines(0, 0, #lines, false, lines)
    end,
    desc = "Sort Brewfiles properly by category on write.",
    pattern = "Brewfile",
})

vim.api.nvim_create_autocmd({ "BufReadPre", "FileReadPre" }, {
    callback = function(args)
        if vim.uv.fs_stat(args.file).size < vim.g.large_file_size then
            return
        end

        vim.g.large_file = true

        vim.notify("File is too large, disabling treesitter, syntax & language servers.")

        for _, client in pairs(vim.lsp.get_active_clients({ bufnr = args.buf })) do
            pcall(vim.lsp.buf_detach_client, args.buf, client.id)
        end

        -- Create a autocommand just in case.
        vim.api.nvim_create_autocmd({ "LspAttach" }, {
            buffer = args.buf,
            callback = function(a)
                vim.lsp.buf_detach_client(args.buf, a.data.client_id)
            end,
        })

        vim.diagnostic.disable()

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
    end,
    desc = "Disable features for large files.",
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    callback = function()
        if vim.tbl_contains(require("config.ignored").buffer_types, vim.bo.buftype) then
            return
        end

        local row, col = unpack(vim.api.nvim_buf_get_mark(0, '"'))
        if row > 0 and row <= vim.api.nvim_buf_line_count(0) then
            vim.api.nvim_win_set_cursor(0, { row, col })
        end
    end,
    desc = "Restore cursor to the last known position.",
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    callback = function()
        local shebang = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]

        if not shebang or not shebang:match("^#!.+") then
            return
        end

        vim.api.nvim_create_autocmd("BufWritePost", {
            callback = function(args)
                local filename = vim.api.nvim_buf_get_name(args.buf)

                local fileinfo = vim.uv.fs_stat(filename)

                if not fileinfo or bit.band(fileinfo.mode - 32768, 0x40) ~= 0 then
                    return
                end

                vim.uv.fs_chmod(filename, bit.bor(fileinfo.mode, 493))
            end,
            once = true,
        })
    end,
    desc = "Mark script files with shebangs as executable on write.",
})

vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
    callback = function(args)
        vim.cmd.bdelete({ args.buf, bang = true })
        vim.cmd.edit(vim.uri_to_fname(args.file))
    end,
    pattern = "file:///*",
    nested = true,
})

vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
    callback = function(args)
        -- This must be called for LSP and other events to work.
        vim.cmd.doautocmd("BufReadPre")

        -- Trailing colon, i.e. ':lnum[:colnum[:]]'
        local pattern = ":?(%d*:?%d*):?$"

        local cwd = (vim.uv.cwd() or vim.fn.getcwd()) .. "/"

        -- Strip off any duplicated parent path.
        local bufname = vim.api.nvim_buf_get_name(args.buf):gsub(cwd, "")
        local capture = bufname:match(pattern)
        local pos = nil
        local fqfn = nil
        local numeric = false

        -- Skip filenames that are all numbers.
        if bufname:match("^%d$") then
            numeric = true
        end

        -- If the next argument is a +<line>
        for i, v in ipairs(vim.v.argv) do
            if v == bufname then
                --
                -- If the next argument is a +<line>
                if vim.v.argv[i + 1] ~= nil and vim.v.argv[i + 1]:match("^+%d+") then
                    pos = { tonumber(vim.v.argv[i + 1]:gsub("%+", "") or 0), 0 }
                end
            end
        end

        if capture and capture ~= "" and not numeric and not pos then
            -- Allow for /path/to/file:<row>:
            pos = vim.split(capture, ":", {})
            pos = { tonumber(pos[1]) or 1, tonumber(pos[2] or 0) or 0 }
        elseif pos == nil and not vim.endswith(bufname, ".plist") then
            -- If the position wasn't set via the filename, check previous marks.
            pos = vim.api.nvim_buf_get_mark(0, '"')
        end

        local path = numeric and bufname or bufname:gsub(pattern, "")

        -- Look for non-qualified paths that aren't cwd local.
        if not bufname:match("^[/~]") and bufname:find("/") then
            --
            -- A partial path almost always comes from git.
            -- Find the root, then strip off the parent path.
            local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1] or cwd

            fqfn = root .. "/" .. path

            if vim.uv.fs_stat(fqfn) then
                path = fqfn
            end
        end

        if pos ~= nil or fqfn ~= nil and vim.uv.fs_stat(path) then
            vim.cmd.file(path)
            vim.cmd.edit({ bang = true })

            if pos then
                vim.api.nvim_buf_set_mark(args.buf, '"', pos[1], pos[2], {})
            end
        end

        vim.cmd.doautocmd("BufReadPost")
    end,
})
