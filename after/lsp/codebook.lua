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
    override = function(config)
        Snacks.toggle({
            name = "Codebook",
            get = function()
                return vim.lsp.is_enabled("codebook")
            end,
            set = function(state)
                vim.lsp.enable("codebook", state)
            end,
        }):map("<space>tk")

        return config
    end,
}
