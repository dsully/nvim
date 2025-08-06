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
            nvim.file.filename(),
        }, {
            stdin = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false),
        }):wait()

        if result.code == 0 and result.stdout then
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(result.stdout, "\n", { trimempty = true }))
        else
            vim.notify("Error running codesort: " .. (result.stderr or ""), vim.log.levels.ERROR)
        end
    end, "Sort code", bufnr)

    keys.vmap("<leader>cs", function()
        local start_line = vim.api.nvim_buf_get_mark(0, "<")[1] or 0
        local end_line = vim.api.nvim_buf_get_mark(0, ">")[1] or 0

        local result = vim.system({ "codesort" }, { stdin = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false) }):wait()

        if result.code == 0 and result.stdout then
            vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, vim.split(result.stdout, "\n", { trimempty = true }))
        else
            vim.notify("Error running codesort: " .. (result.stderr or ""), vim.log.levels.ERROR)
        end
    end, "Sort code", bufnr)
end
