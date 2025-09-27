---@type vim.lsp.ClientConfig
return require("schema-companion").setup_client(
    require("schema-companion").adapters.taplo.setup({
        sources = {
            require("schema-companion").sources.lsp.setup(),
            require("schema-companion").sources.none.setup(),
        },
    }),
    ---@diagnostic disable-next-line: param-type-not-match
    {
        --- @param client vim.lsp.Client
        on_init = function(client)
            keys.map("<leader>vs", function()
                local schema = require("schema-companion").get_current_schemas()

                if schema then
                    Snacks.notify.info(schema)
                end
            end, "Show YAML schema")
        end,
    }
)
