---@type vim.lsp.Config
return {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yaml.github" },
    handlers = {
        ["yaml/schema/store/initialized"] = function(...)
            require("schema-companion.lsp").store_initialized(...)
        end,
    },
    --- @param client vim.lsp.Client
    --- @param bufnr integer
    on_attach = function(client, bufnr)
        local context = require("schema-companion.context")

        context.setup(bufnr, client)

        keys.bmap("<leader>vs", function()
            local schema = context.get_buffer_schema(bufnr)

            if schema.name then
                Snacks.notify.info(schema.name)
            end
        end, "Show YAML schema", bufnr)
    end,
    --- @param client vim.lsp.Client
    on_init = function(client)
        local schemas = nvim.file.read(nvim.file.xdg_config("schemas.json")) or "{}"

        ---@diagnostic disable-next-line: inject-field, need-check-nil
        client.config.settings.yaml.schemas = require("schemastore").yaml.schemas({
            extra = vim.json.decode(schemas),
        })

        client:notify(vim.lsp.protocol.Methods.workspace_didChangeConfiguration, { settings = client.config.settings })

        client:notify("yaml/supportSchemaSelection" --[[@as vim.lsp.protocol.Method.ClientToServer.Notification]], { {} })
    end,
    settings = {
        redhat = {
            telemetry = {
                enabled = false,
            },
        },
        yaml = {
            format = {
                enable = true,
                singleQuote = false,
            },
            editor = {
                formatOnType = false,
            },
            hover = true,
            schemaStore = {
                enable = false,
                url = "",
            },
            validate = true,
        },
    },
}
