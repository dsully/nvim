---@type vim.lsp.Config
return {
    cmd = { "fish-lsp", "start" },
    cmd_env = { fish_lsp_show_client_popups = false },
    filetypes = {
        "fish",
        "fish.gotmpl",
    },
    on_attach = function(client)
        if client.server_capabilities then
            client.server_capabilities.documentOnTypeFormattingProvider = nil
        end
    end,
    single_file_support = true,
}
