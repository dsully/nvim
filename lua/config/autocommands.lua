--
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
        vim.wo.foldenable = false
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
        if vim.uv.fs_stat(args.file).size < 1024 * 512 then
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
        vim.wo.foldmethod = "manual"
        vim.wo.list = false
        vim.wo.spell = false
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

-- Jump to a row and column if given on the command line.
vim.api.nvim_create_autocmd({ "VimEnter" }, {
    callback = function()
        -- Skip if no arguments were passed.
        if #vim.v.argv == 2 then
            return
        end

        -- Trailing colon, i.e. ':lnum[:colnum[:]]'
        local pattern = ":?(%d*:?%d*):?$"

        local cwd = (vim.uv.cwd() or vim.fn.getcwd()) .. "/"

        local function process(buffer)
            if not vim.bo[buffer].buflisted then
                return
            end

            -- Strip off any duplicated parent path.
            local bufname = vim.api.nvim_buf_get_name(buffer):gsub(cwd, "")
            local capture = bufname:match(pattern)
            local pos = nil
            local fqfn = nil
            local numeric = false

            -- Skip if the next argument is a +<line>
            if vim.v.argv[#vim.v.argv]:match("^+%d+") then
                return
            end

            -- Skip filenames that are all numbers.
            if bufname:match("^%d$") then
                numeric = true
            end

            if capture and capture ~= "" and not numeric then
                -- Allow for /path/to/file:<row>:
                pos = vim.split(capture, ":", {})
                pos = { tonumber(pos[1]) or 1, tonumber(pos[2] or 0) or 0 }
            else
                local row, col = unpack(vim.api.nvim_buf_get_mark(buffer, '"'))
                if row > 0 and row <= vim.api.nvim_buf_line_count(0) then
                    pos = { row, col }
                end
            end

            local path = numeric and bufname or bufname:gsub(pattern, "")

            -- Look for non-qualified paths that aren't cwd local.
            if not bufname:match("^[/~]") and bufname:find("/") then
                --
                -- A partial path almost always comes from git.
                -- Find the root, then strip off the parent path.
                local root = vim.fn.systemlist('git rev-parse --show-toplevel')[1] or cwd

                fqfn = root .. "/" .. path

                if vim.uv.fs_stat(fqfn) then
                    path = fqfn
                end
            end

            -- Return early if there's no pattern and the file exists.
            if pos == nil and fqfn == nil then
                return
            end

            -- Clean up the argument list.
            vim.api.nvim_buf_set_name(buffer, path)
            vim.bo[buffer].modified = false

            vim.cmd(".argdelete")
            vim.cmd.argadd(vim.fn.fnameescape(path))

            if vim.uv.fs_stat(path) then
                vim.cmd.edit(path)
            end

            if pos then
                vim.api.nvim_win_set_cursor(0, pos)
            end
        end

        for _, b in ipairs(vim.api.nvim_list_bufs()) do
            process(b)
        end

        vim.cmd.bfirst()
    end,
    once = true,
    nested = true,
})
