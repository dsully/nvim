return require("schema-companion").setup_client(
    require("schema-companion").adapters.jsonls.setup({
        sources = {
            require("schema-companion").sources.lsp.setup(),
            require("schema-companion").sources.none.setup(),
        },
    }),
    {
        ---@type table<vim.lsp.protocol.Method.ServerToClient.Notification, lsp.Handler>
        handlers = {
            ---@type lsp.Handler
            ["textDocument/publishDiagnostics"] = function(err, result, ctx)
                ---
                ---@diagnostic disable-next-line: param-type-not-match
                result.diagnostics = vim.tbl_filter(function(diagnostic)
                    -- disable diagnostics for trailing comma in JSONC
                    if diagnostic.code == 519 then
                        return false
                    end

                    return true
                end, result.diagnostics)
                vim.lsp.handlers[ctx.method](err, result, ctx)
            end,
        },
        init_options = {
            provideFormatter = false,
        },
        --- @param client vim.lsp.Client
        on_init = function(client)
            local schemas = nvim.file.read(nvim.file.xdg_config("schemas.json")) or "{}"

            ---@diagnostic disable-next-line: inject-field, need-check-nil
            client.config.settings.json.schemas = require("schemastore").json.schemas({
                extra = vim.json.decode(schemas),
            })

            client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end,
        settings = {
            json = {
                format = {
                    enable = false,
                },
                schemas = {},
                schemaDownload = {
                    enable = true,
                },
                validate = {
                    enable = true,
                },
            },
        },
    }
)
