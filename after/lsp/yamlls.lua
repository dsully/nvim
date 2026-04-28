---@type vim.lsp.ClientConfig
return {
    filetypes = {
        "yaml",
        "yaml.github",
        "!yaml.ansible",
    },
    ---@diagnostic disable-next-line: param-type-mismatch
    --- @param client vim.lsp.Client
    on_init = function(client)
        --- Since formatting is disabled by default if you check `client:supports_method('textDocument/formatting')`
        --- during `LspAttach` it will return `false`. This hack sets the capability to `true` to facilitate
        --- autocmd's which check this capability
        if client.server_capabilities then
            client.server_capabilities.documentFormattingProvider = true
        end

        local schemas = nvim.file.read(nvim.file.xdg_config("schemas.json"))

        if schemas ~= nil then
            local settings = client.config.settings --[[@as table]]
            settings.yaml.schemas = require("schemastore").yaml.schemas({
                extra = vim.json.decode(schemas),
            })

            client:notify("workspace/didChangeConfiguration", { settings = settings })
        end

        client:notify("yaml/supportSchemaSelection" --[[@as vim.lsp.protocol.Method.ClientToServer.Notification]], { {} })
    end,
    override = function(config)
        return require("schema-companion").setup_client(
            require("schema-companion").adapters.yamlls.setup({
                sources = {
                    require("schema-companion").sources.lsp.setup(),
                    require("schema-companion").sources.schemas.setup(),
                },
            }),
            config
        )
    end,
    settings = {
        flags = {
            debounce_text_changes = 50,
        },
        redhat = { telemetry = { enabled = false } },
        yaml = {
            completion = true,
            editor = {
                formatOnType = true,
            },
            format = {
                enable = true,
                singleQuote = false,
            },
            hover = true,
            schemas = {},
            schemaStore = {
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json",
            },
            validate = true,
        },
    },
}
