---@type vim.lsp.ClientConfig
return {
    handlers = {
        ---@type lsp.Handler
        ["textDocument/publishDiagnostics"] = function(err, result, ctx)
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
    on_attach = function(client, bufnr)
        require("ck.lsp.handlers").on_attach(client, bufnr)
        require("ck.lsp.handlers").overwrite_capabilities_with_no_formatting(client, bufnr)
    end,
    on_init = function(client)
        local schemas = nvim.file.read(nvim.file.xdg_config("schemas.json")) or "{}"

        ---@diagnostic disable-next-line: inject-field, need-check-nil
        client.config.settings.json.schemas = require("schemastore").json.schemas({
            extra = vim.json.decode(schemas),
        })

        client:notify(vim.lsp.protocol.Methods.workspace_didChangeConfiguration, { settings = client.config.settings })
    end,
    settings = {
        json = {
            format = {
                enable = false,
            },
            schemas = vim.tbl_deep_extend("force", require("schemastore").json.schemas(), {
                {
                    description = "TypeScript compiler configuration file",
                    fileMatch = { "tsconfig.json", "tsconfig.*.json" },
                    url = "https://json.schemastore.org/tsconfig.json",
                },
                {
                    description = "JSON Schema.",
                    fileMatch = { "*.schema.json" },
                    url = "http://json-schema.org/draft-07/schema#",
                },
            }),
            schemaDownload = {
                enable = true,
            },
            validate = {
                enable = true,
            },
        },
    },
    setup = {
        commands = {
            Format = {
                function()
                    vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
                end,
            },
        },
    },
}
