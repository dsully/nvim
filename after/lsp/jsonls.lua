return {
    ---@diagnostic disable-next-line: param-type-mismatch
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
        local schemas = nvim.file.read(nvim.file.xdg_config("schemas.json"))

        if schemas ~= nil then
            local settings = client.config.settings --[[@as table]]
            settings.json.schemas = require("schemastore").json.schemas({
                extra = vim.json.decode(schemas),
            })

            client:notify("workspace/didChangeConfiguration", { settings = settings })
        end
    end,
    override = function(config)
        return require("schema-companion").setup_client(
            require("schema-companion").adapters.jsonls.setup({
                sources = {
                    require("schema-companion").sources.lsp.setup(),
                    require("schema-companion").sources.none.setup(),
                },
            }),
            config
        )
    end,
    settings = {
        json = {
            format = {
                enable = false,
            },
            schemaDownload = {
                enable = true,
            },
            validate = {
                enable = true,
            },
        },
    },
}
