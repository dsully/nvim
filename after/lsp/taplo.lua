---@type vim.lsp.ClientConfig
return {
    override = function(config)
        return require("schema-companion").setup_client(
            require("schema-companion").adapters.taplo.setup({
                sources = {
                    require("schema-companion").sources.lsp.setup(),
                    require("schema-companion").sources.none.setup(),
                },
            }),
            config
        )
    end,
    settings = {
        settings = {},
    },
}
