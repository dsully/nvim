local bufnr = vim.api.nvim_get_current_buf()

-- https://github.com/Canop/codesort
-- cargo install codesort
if vim.fn.executable("codesort") == 1 then
    --
    keys.bmap("<leader>cs", function()
        local current_line = vim.api.nvim_win_get_cursor(0)[1]
        local filename = vim.fn.shellescape(vim.api.nvim_buf_get_name(0):match("([^/\\]+)$"))

        vim.api.nvim_buf_set_mark(0, "a", current_line, 0, {})
        vim.cmd(string.format("%%!codesort --around %d --detect %s", current_line, filename))
        vim.cmd.normal({ "`a", bang = true })
    end, "Sort code", bufnr)

    keys.xmap("<leader>cs", function()
        vim.cmd(string.format("%d,%d!codesort", vim.fn.line("'<"), vim.fn.line("'>")))
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

do
    -- Start bacon in clippy mode if it exists.
    -- vim.schedule(function()
    --     if vim.uv.fs_access("bacon.toml", "R") then
    --         vim.cmd.OverseerRun("bacon")
    --     end
    -- end)
end
