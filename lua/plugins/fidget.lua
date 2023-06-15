return {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
        sources = {
            ["copilot"] = { ignore = true },
            ["ltex"] = { ignore = true },
            ["null-ls"] = { ignore = true },
            ["pylance"] = { ignore = true },
            ["pyright"] = { ignore = true },
            ["ruff_lsp"] = { ignore = true },
        },
        text = { spinner = "dots" },
    },
    tag = "legacy",
}
