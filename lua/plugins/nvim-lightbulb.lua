return {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",
    opts = {
        autocmd = {
            enabled = true,
        },
        ignore = {
            clients = require("config..defaults").ignored.lsp,
        },
        sign = {
            enabled = true,
            text = "󰌶",
            hl = "LspDiagnosticsDefaultInformation",
        },
    },
}
