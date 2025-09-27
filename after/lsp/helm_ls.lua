-- https://github.com/someone-stole-my-name/schema-companion.nvim/issues/12#issuecomment-1367850121
---@type vim.lsp.ClientConfig
return require("schema-companion").setup_client(
    require("schema-companion").adapters.helmls.setup({
        sources = {
            require("schema-companion").sources.lsp.setup(),
            require("schema-companion").sources.matchers.kubernetes.setup({ version = "master" }),
        },
    }),
    ---@diagnostic disable-next-line: param-type-not-match
    {
        --- @param client vim.lsp.Client
        on_init = function(client)
            local schemas = nvim.file.read(nvim.file.xdg_config("schemas.json")) or "{}"

            ---@diagnostic disable-next-line: inject-field, need-check-nil
            client.config.settings.json.schemas = require("schemastore").json.schemas({
                extra = vim.json.decode(schemas),
            })

            client:notify(vim.lsp.protocol.Methods.workspace_didChangeConfiguration, { settings = client.config.settings })
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
    }
)
