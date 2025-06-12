---@type vim.lsp.Config
return {
    cmd = { "tombi", "lsp" },
    filetypes = { "toml", "toml.pyproject" },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        --
        if client.server_capabilities then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            client.server_capabilities.documentOnTypeFormattingProvider = nil
        end
    end,
    single_file_support = true,
}
