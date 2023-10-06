return {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",
    opts = {
        autocmd = {
            enabled = true,
        },
        ignore = {
            clients = vim.g.defaults.ignored.lsp,
        },
        sign = {
            enabled = true,
            text = "󰌶",
            hl = "LspDiagnosticsDefaultInformation",
        },
    },
}
