---@type vim.lsp.Config
return {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml" },
    handlers = {
        ["yaml/schema/store/initialized"] = function(...)
            require("schema-companion.lsp").store_initialized(...)
        end,
    },
    --- @param client vim.lsp.Client
    --- @param bufnr integer
    on_attach = function(client, bufnr)
        require("schema-companion.context").setup(bufnr, client)

        keys.bmap("<leader>vs", function()
            local schema = require("schema-companion.context").get_buffer_schema(bufnr)

            if schema and schema.name then
                notify.info(schema.name)
            end
        end, "Show YAML schema", bufnr)
    end,
    --- @param client vim.lsp.Client
    on_init = function(client)
        client:notify("yaml/supportSchemaSelection", { {} })
    end,
    on_new_config = function(config)
        config.settings = vim.tbl_deep_extend("force", config.settings, {
            yaml = { schemas = require("schemastore").yaml.schemas() },
        })
    end,
    settings = {
        redhat = {
            telemetry = {
                enabled = false,
            },
        },
        yaml = {
            validate = true,
            format = {
                enable = true,
                singleQuote = false,
            },
            hover = true,
        },
    },
}
