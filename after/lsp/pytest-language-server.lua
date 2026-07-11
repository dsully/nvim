---@type vim.lsp.Config
return {
    ---@param client vim.lsp.Client
    on_attach = function(client)
        if client.server_capabilities then
            client.server_capabilities.hoverProvider = nil
        end
    end,
    single_file_support = true,
}
