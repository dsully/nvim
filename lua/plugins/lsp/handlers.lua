local M = {}

M.setup = function()
    -- Jump directly to the first available definition every time.
    -- Use Telescope if there is more than one result.
    vim.lsp.handlers["textDocument/definition"] = function(_, result, ctx)
        if not result or vim.tbl_isempty(result) then
            vim.api.nvim_echo({ { "LSP: Could not find definition" } }, false, {})
            return
        end

        local client = vim.lsp.get_client_by_id(ctx.client_id)

        if not client then
            return
        end

        if vim.tbl_islist(result) then
            local results = vim.lsp.util.locations_to_items(result, client.offset_encoding)
            local lnum, filename = results[1].lnum, results[1].filename

            for _, val in pairs(results) do
                if val.lnum ~= lnum or val.filename ~= filename then
                    return require("telescope.builtin").lsp_definitions()
                end
            end

            vim.lsp.util.jump_to_location(result[1], client.offset_encoding, false)
        else
            vim.lsp.util.jump_to_location(result, client.offset_encoding, true)
        end
    end

    --
    -- See: https://github.com/neovim/neovim/issues/19649
    local original = vim.lsp.handlers["textDocument/publishDiagnostics"]

    vim.lsp.handlers["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
        vim.tbl_map(function(item)
            if item.relatedInformation and #item.relatedInformation > 0 then
                vim.tbl_map(function(k)
                    if k.location then
                        --
                        k.message = vim.fn.fnamemodify(vim.uri_to_fname(k.location.uri), ":t")
                            .. "("
                            .. (k.location.range.start.line + 1)
                            .. ", "
                            .. (k.location.range.start.character + 1)
                            .. "): "
                            .. k.message

                        if k.location.uri == vim.uri_from_bufnr(0) then
                            table.insert(result.diagnostics, {
                                code = item.code,
                                message = k.message,
                                range = k.location.range,
                                severity = vim.lsp.protocol.DiagnosticSeverity.Hint,
                                source = item.source,
                                relatedInformation = {},
                            })
                        end
                    end
                    item.message = item.message .. "\n" .. k.message
                end, item.relatedInformation)
            end
        end, result.diagnostics)

        original(_, result, ctx, config)
    end
end

return M
