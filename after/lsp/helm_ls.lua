---@type vim.lsp.ClientConfig
return {
    override = function(config)
        return require("schema-companion").setup_client(
            require("schema-companion").adapters.helmls.setup({
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
            }),
            config
        )
    end,
    ---@diagnostic disable-next-line: param-type-mismatch
    --- @param client vim.lsp.Client
    on_init = function(client)
        local schemas = nvim.file.read(nvim.file.xdg_config("schemas.json"))

        if schemas ~= nil then
            ---@diagnostic disable-next-line: inject-field, need-check-nil
            client.config.settings["helm-ls"].yamlls.schemas = require("schemastore").yaml.schemas({
                extra = vim.json.decode(schemas),
            })

            client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
    end,
    settings = {
        flags = {
            debounce_text_changes = 50,
        },

        ["helm-ls"] = {
            helmLint = {
                enabled = true,
                ignoredMessages = {},
            },
            logLevel = "info",
            valuesFiles = {
                additionalValuesFilesGlobPattern = "values*.yaml",
                lintOverlayValuesFile = "values.lint.yaml",
                mainValuesFile = "values.yaml",
            },
            yamlls = {
                enabled = true,
                enabledForFilesGlob = "*.{gotmpl,tpl}",
                diagnosticsLimit = 50,
                showDiagnosticsDirectly = false,
                path = "yaml-language-server",
                initTimeoutSeconds = 3,
                config = {
                    completion = true,
                    format = {
                        enable = true,
                    },
                    hover = true,
                    schemaStore = {
                        enable = true,
                        url = "https://www.schemastore.org/api/json/catalog.json",
                    },
                    validate = true,
                },
            },
        },
    },
}
