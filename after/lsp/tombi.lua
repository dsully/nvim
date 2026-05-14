---@type vim.lsp.ClientConfig
return require("schema-companion").setup_client(
    require("schema-companion").adapters.tombi.setup({
        sources = {
            require("schema-companion").sources.lsp.setup(),
            require("schema-companion").sources.none.setup(),
        },
    }),
    {
        -- Settings
    }
)
