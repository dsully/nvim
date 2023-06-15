return {
    "SmiteshP/nvim-navic",
    init = function()
        vim.g.navic_silence = true
    end,
    opts = {
        highlight = true,
        lsp = {
            auto_attach = true,
            preference = { "pyright" },
        },
    },
}
