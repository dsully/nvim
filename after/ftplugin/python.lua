vim.api.nvim_create_autocmd("InsertCharPre", {
    pattern = { "python" },
    desc = "Treesitter automatic Python format strings",
    group = vim.api.nvim_create_augroup("py-fstring", { clear = true }),
    callback = function(args)
        -- Only run if f-string escape character is typed
        if vim.v.char ~= "{" then
            return
        end

        -- Get node and return early if not in a string
        local node = vim.treesitter.get_node()

        if not node then
            return
        end

        if node:type() ~= "string" then
            node = node:parent()

            if not node or node:type() ~= "string" then
                return
            end
        end

        local row, col, _, _ = vim.treesitter.get_node_range(node)

        -- Return early if string is already a format string
        local first_char = vim.api.nvim_buf_get_text(args.buf, row, col, row, col + 1, {})[1]

        if first_char == "f" then
            return
        end

        -- Otherwise, make the string a format string
        vim.api.nvim_input("<Esc>m'" .. row + 1 .. "gg" .. col + 1 .. "|if<Esc>`'la")
    end,
})
