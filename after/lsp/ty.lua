---@type vim.lsp.Config
return {
    cmd = {
        "ty",
        "server",
    },
    filetypes = { "python" },
    handlers = {
        ["window/showMessage"] = function(_, result)
            if result and result.type == vim.lsp.protocol.MessageType.Error then
                return -- silence error notifications from ty
            end
        end,
        -- ty exposes no server-side severity filter, so drop "info" diagnostics client-side.
        ["textDocument/diagnostic"] = function(err, result, ctx)
            if result and result.items then
                result.items = vim.tbl_filter(function(diagnostic)
                    return diagnostic.severity ~= vim.lsp.protocol.DiagnosticSeverity.Information
                end, result.items)
            end
            return vim.lsp.diagnostic.on_diagnostic(err, result, ctx)
        end,
    },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        if client.server_capabilities then
        end
    end,
    -- Silence ty server panics (e.g. https://github.com/astral-sh/ty/issues/2401)
    on_error = function(_, _) end,
    root_markers = {
        "Pipfile",
        "pyproject.toml",
        "pyrightconfig.json",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
    },
    settings = {
        ty = {
            diagnosticMode = "workspace",
        },
    },
    single_file_support = true,
}
