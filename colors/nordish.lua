vim.g.colors_name = "nordish"
vim.o.background = "dark"

vim.cmd.highlight("clear")

for name, opts in pairs(defaults.highlights) do
    vim.api.nvim_set_hl(0, name, opts)
end
