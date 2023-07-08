return {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",
    opts = {
        autocmd = {
            enabled = true,
        },
        ignore = {
            clients = {
                "copilot",
            },
        },
        sign = {
            enabled = true,
            text = "󰌶",
            hl = "LspDiagnosticsDefaultInformation",
        },
    },
}
