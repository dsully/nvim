local bufnr = vim.api.nvim_get_current_buf()

-- https://github.com/Canop/codesort
-- cargo install codesort
if vim.fn.executable("codesort") == 1 then
    --
    keys.bmap("<leader>cs", function()
        --
        local result = vim.system({
            "codesort",
            "--around",
            tostring(vim.api.nvim_win_get_cursor(0)[1]),
            "--detect",
            vim.fs.normalize(vim.fs.basename(vim.api.nvim_buf_get_name(0))),
        }, {
            stdin = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false),
        }):wait()

        if result.code == 0 and result.stdout then
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(result.stdout, "\n", { trimempty = true }))
        else
            vim.notify("Error running codesort: " .. (result.stderr or ""), vim.log.levels.ERROR)
        end
    end, "Sort code", bufnr)

    keys.xmap("<leader>cs", function()
        local start_line = vim.api.nvim_buf_get_mark(0, "<")[1]
        local end_line = vim.api.nvim_buf_get_mark(0, ">")[1]

        local result = vim.system({ "codesort" }, { stdin = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false) }):wait()

        if result.code == 0 and result.stdout then
            vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, vim.split(result.stdout, "\n", { trimempty = true }))
        else
            vim.notify("Error running codesort: " .. (result.stderr or ""), vim.log.levels.ERROR)
        end
    end, "Sort code", bufnr)
end

-- Insert Clippy allow directive above the current line
keys.bmap("<leader>ri", function()
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1

    ---@type lsp.Diagnostic[]
    local diagnostics = vim.lsp.diagnostic.from(vim.diagnostic.get(bufnr, { lnum = line }))

    for _, diagnostic in ipairs(diagnostics) do
        if diagnostic.source == "clippy" then
            --
            -- Match both the new pattern and the old pattern
            local directive = diagnostic.message:match("`#%[deny%(clippy::([%w_]+)%)%]`") or diagnostic.message:match("add `(#%[allow%(clippy::[%w_%-]+%)%])`")

            if directive then
                -- If it's the new pattern, construct the full directive
                if not directive:match("^#%[") then
                    directive = string.format("#[allow(clippy::%s)]", directive)
                end

                vim.api.nvim_buf_set_lines(bufnr, line, line, false, { directive })
                return
            end
        end

        if diagnostic.source == "rustc" then
            local directive = diagnostic.message:match("`(#%[deny%([%w_%-]+%)%])`") or diagnostic.message:match("`(#%[warn%([%w_%-]+%)%])`")

            if directive then
                directive = directive:gsub("%[deny", "[allow"):gsub("%[warn", "[allow")
                vim.api.nvim_buf_set_lines(bufnr, line, line, false, { directive })
                return
            end
        end
    end
end, "Insert Clippy Allow", bufnr)
