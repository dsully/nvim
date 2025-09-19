---@type vim.lsp.Config
return {
    cmd = { "codebook-lsp", "serve" },
    filetypes = {
        "c",
        "css",
        "go",
        "html",
        "javascript",
        "javascriptreact",
        "markdown",
        "python",
        "rust",
        "toml",
        "typescript",
        "typescriptreact",
    },
    root_markers = {
        "codebook.toml",
        ".codebook.toml",
    },
}
