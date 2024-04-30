local M = {}

M.setup = function()

    -- De-duplicate diagnostics, in particular from rust-analyzer/rustc
    ---@param result lsp.PublishDiagnosticsParams
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(function(_, result, ...)
        --
        ---@type table<string, lsp.Diagnostic>>
        local seen = {}

        ---@param diagnostic lsp.Diagnostic
        for _, diagnostic in ipairs(result.diagnostics) do
            local key = string.format("%s:%s", diagnostic.code, diagnostic.range.start.line)

            seen[key] = diagnostic
        end

        result.diagnostics = vim.tbl_values(seen)

        vim.lsp.diagnostic.on_publish_diagnostics(_, result, ...)
    end, {})

    -- Handle dynamic registration.
    --
    -- https://github.com/neovim/neovim/issues/24229
    local register_capability = vim.lsp.handlers["client/registerCapability"]

    --
    ---@param res lsp.RegistrationParams
    ---@param ctx lsp.HandlerContext
    vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
        local client_id = ctx.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        local buffer = vim.api.nvim_get_current_buf()

        if client then
            require("plugins.lsp.common").on_attach(client, buffer)
        end

        return register_capability(err, res, ctx)
    end
end

return M
