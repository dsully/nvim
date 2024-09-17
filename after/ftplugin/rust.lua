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
