vim.o.autoindent = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.softtabstop = 4
vim.o.tabstop = 4

-- Set the indent after opening parenthesis
vim.g.pyindent_open_paren = vim.bo.shiftwidth

vim.cmd.inoreabbrev("<buffer> true True")
vim.cmd.inoreabbrev("<buffer> false False")
vim.cmd.inoreabbrev("<buffer> null None")
vim.cmd.inoreabbrev("<buffer> none None")
vim.cmd.inoreabbrev("<buffer> nil None")

-- Automatically make the current string an f-string when typing `{`.
ev.on(ev.InsertCharPre, function(params)
    if vim.v.char ~= "{" then
        return
    end

    local node = vim.treesitter.get_node({})

    if not node then
        return
    end

    if node:type() ~= "string" then
        node = node:parent()
    end

    if not node or node:type() ~= "string" then
        return
    end

    local row, col, _, _ = vim.treesitter.get_node_range(node)
    local first_char = vim.api.nvim_buf_get_text(params.buf, row, col, row, col + 1, {})[1]

    if first_char == "f" or first_char == "r" then
        return
    end

    vim.api.nvim_input("<Esc>m'" .. row + 1 .. "gg" .. col + 1 .. "|if<esc>`'la")
end, {
    group = ev.group("py-fstring"),
    pattern = { "*.py" },
})

vim.b.miniai_config = {
    custom_textobjects = {
        t = require("mini.ai").gen_spec.treesitter({ a = "@annotation.outer", i = "@annotation.outer" }),
    },
}
