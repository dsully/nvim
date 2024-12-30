return {
    cmd = { "yaml-language-server", "--stdio" },
    commands = {
        YAMLSchema = {
            function()
                local schema = require("schema-companion").get_buf_schema(vim.api.nvim_get_current_buf())

                if schema.result[1].name ~= "none" then
                    notify.info(schema.result[1].name)
                end
            end,
            desc = "Show YAML schema",
        },
    },
    filetypes = { "yaml" },
    handlers = {
        ["yaml/schema/store/initialized"] = function()
            require("schema-companion.lsp").store_initialized()
        end,
    },
    --- @param client vim.lsp.Client
    --- @param bufnr integer
    on_attach = function(client, bufnr)
        require("schema-companion.context").setup(bufnr, client)
    end,
    --- @param client vim.lsp.Client
    on_init = function(client)
        client:notify("yaml/supportSchemaSelection", { {} })
        return true
    end,
    on_new_config = function(config)
        config.settings = vim.tbl_deep_extend("force", config.settings, {
            yaml = { schemas = require("schemastore").yaml.schemas() },
        })

        keys.map("<leader>vs", vim.cmd.YAMLSchema, "Show YAML schema")
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
