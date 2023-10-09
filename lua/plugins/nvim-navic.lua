return {
    "SmiteshP/nvim-navic",
    event = "VeryLazy",
    init = function()
        vim.g.navic_silence = true
    end,
    opts = {
        highlight = true,
        lazy_update_context = true,
        lsp = {
            auto_attach = true,
            preference = { "pyright" },
        },
    },
}
