---@type vim.lsp.Config
return {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    ---@type table<vim.lsp.protocol.Methods, lsp.Handler>
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
        json = {
            format = {
                enable = false,
            },
            schemas = {},
            validate = {
                enable = true,
            },
        },
    },
}
