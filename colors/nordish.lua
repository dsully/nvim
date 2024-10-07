vim.g.colors_name = "nordish"
vim.o.background = "dark"

vim.cmd.highlight("clear")

--- FIXME: Temporary until I can figure out load order or move all plugin highlight settings to ColorSchemePre
hl.apply({
    { MiniIconsAzure = { fg = colors.blue.bright } },
    { MiniIconsBlue = { fg = colors.blue.base } },
    { MiniIconsCyan = { fg = colors.cyan.base } },
    { MiniIconsGreen = { fg = colors.green.base } },
    { MiniIconsGrey = { fg = colors.gray.bright } },
    { MiniIconsOrange = { fg = colors.orange.base } },
    { MiniIconsPurple = { fg = colors.magenta.base } },
    { MiniIconsRed = { fg = colors.red.base } },
    { MiniIconsYellow = { fg = colors.yellow.base } },
})

for name, opts in pairs(defaults.highlights) do
    vim.api.nvim_set_hl(0, name, opts)
end
