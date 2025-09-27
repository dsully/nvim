-- https://github.com/someone-stole-my-name/schema-companion.nvim/issues/12#issuecomment-1367850121
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
    settings = {
        flags = {
            debounce_text_changes = 50,
        },
        ["helm-ls"] = {
            yamlls = {
                enabled = true,
                diagnosticsLimit = 50,
                showDiagnosticsDirectly = false,
                path = "yaml-language-server",
                config = {
                    validate = true,
                    format = { enable = true },
                    completion = true,
                    hover = true,
                    schemaDownload = { enable = true },
                    schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
                    -- any other config: https://github.com/redhat-developer/yaml-language-server#language-server-settings
                },
            },
        },
    },
}
