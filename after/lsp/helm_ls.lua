-- https://github.com/someone-stole-my-name/schema-companion.nvim/issues/12#issuecomment-1367850121
---@type vim.lsp.ClientConfig
return require("schema-companion").setup_client(
    require("schema-companion").adapters.helmls.setup({
        sources = {
            require("schema-companion").sources.lsp.setup(),
            require("schema-companion").sources.matchers.kubernetes.setup({ version = "master" }),
        },
    }),
    {
        --- @param client vim.lsp.Client
        on_init = function(client)
            local schemas = nvim.file.read(nvim.file.xdg_config("schemas.json")) or "{}"

            ---@diagnostic disable-next-line: inject-field, need-check-nil
            client.config.settings["helm-ls"].yamlls.schemas = require("schemastore").yaml.schemas({
                extra = vim.json.decode(schemas),
            })

            client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
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
                    enabledForFilesGlob = "*.{yaml,yml,yaml.gotmpl,tpl}",
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
                        schemas = {},
                        schemaDownload = {
                            enable = true,
                        },
                        validate = true,
                    },
                },
            },
        },
    } -- [[@as vim.lsp.ClientConfig ]]
)
