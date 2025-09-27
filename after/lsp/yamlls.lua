---@type vim.lsp.ClientConfig
return require("schema-companion").setup_client(
    require("schema-companion").adapters.yamlls.setup({
        sources = {
            require("schema-companion").sources.matchers.kubernetes.setup({ version = "master" }),
            require("schema-companion").sources.lsp.setup(),
            require("schema-companion").sources.schemas.setup({
                {
                    name = "Kubernetes master",
                    uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json",
                },
                {
                    name = "Kubernetes v1.27",
                    uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.27.16-standalone-strict/all.json",
                },
                {
                    name = "Kubernetes v1.28",
                    uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.28.12-standalone-strict/all.json",
                },
                {
                    name = "Kubernetes v1.29",
                    uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.29.7-standalone-strict/all.json",
                },
                {
                    name = "Kubernetes v1.30",
                    uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.30.3-standalone-strict/all.json",
                },
            }),
        },
        require("schema-companion").sources.none.setup(),
    }),
    ---@diagnostic disable-next-line: param-type-not-match
    {
        --- @param client vim.lsp.Client
        on_init = function(client)
            --- Since formatting is disabled by default if you check `client:supports_method('textDocument/formatting')`
            --- during `LspAttach` it will return `false`. This hack sets the capability to `true` to facilitate
            --- autocmd's which check this capability
            if client.server_capabilities then
                client.server_capabilities.documentFormattingProvider = true
            end

            local schemas = nvim.file.read(nvim.file.xdg_config("schemas.json")) or "[]"

            ---@diagnostic disable-next-line: inject-field, need-check-nil
            client.config.settings.yaml.schemas = require("schemastore").yaml.schemas({
                extra = vim.json.decode(schemas),
            })

            client:notify(vim.lsp.protocol.Methods.workspace_didChangeConfiguration, { settings = client.config.settings })

            client:notify("yaml/supportSchemaSelection" --[[@as vim.lsp.protocol.Method.ClientToServer.Notification]], { {} })
        end,
        filetypes = {
            "yaml",
            "yaml.github",
            "!yaml.ansible",
        },
        settings = {
            flags = {
                debounce_text_changes = 50,
            },
            redhat = { telemetry = { enabled = false } },
            yaml = {
                completion = true,
                editor = {
                    formatOnType = false,
                },
                format = {
                    enable = true,
                    singleQuote = false,
                },
                hover = true,
                schemas = {},
                schemaStore = {
                    enable = false,
                    url = "",
                },
                validate = true,
            },
        },
    }
)
