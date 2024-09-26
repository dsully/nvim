-- https://github.com/Canop/codesort
-- cargo install codesort
if vim.fn.executable("codesort") == 1 then
    --
    keys.map("<localleader>cs", function()
        local current_line = vim.api.nvim_win_get_cursor(0)[1]
        local filename = vim.fn.shellescape(vim.api.nvim_buf_get_name(0):match("([^/\\]+)$"))

        vim.api.nvim_buf_set_mark(0, "a", current_line, 0, {})
        vim.cmd(string.format("%%!codesort --around %d --detect %s", current_line, filename))
        vim.cmd("normal! `a")
    end, "Sort code")

    keys.map("<localleader>cs", function()
        vim.cmd(string.format("%d,%d!codesort", vim.fn.line("'<"), vim.fn.line("'>")))
    end, "Sort code", { "x" })
end

-- Insert Clippy allow directive above the current line
keys.map("<leader>ri", function()
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local bufnr = vim.api.nvim_get_current_buf()

    ---@type lsp.Diagnostic[]
    local diagnostics = vim.lsp.diagnostic.from(vim.diagnostic.get(bufnr, { lnum = line }))

    for _, diagnostic in ipairs(diagnostics) do
        if diagnostic.source == "clippy" then
            --
            local allow_directive = diagnostic.message:match("add `(#[allow(clippy::[%w_%-]+%)])`")

            if allow_directive then
                vim.api.nvim_buf_set_lines(bufnr, line, line, false, { allow_directive })
                return
            end
        end

        if diagnostic.source == "rustc" then
            local allow_directive = diagnostic.message:match("`(#[warn([%w_%-]+%)])`")

            if allow_directive then
                allow_directive = allow_directive:gsub("%[warn", "[allow")

                vim.api.nvim_buf_set_lines(bufnr, line, line, false, { allow_directive })

                return
            end
        end
    end
end, "Insert Clippy Allow")
