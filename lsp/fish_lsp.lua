---@type vim.lsp.Config
return {
    cmd = { "fish-lsp", "start" },
    cmd_env = { fish_lsp_show_client_popups = false },
    filetypes = {
        "fish",
        "fish.gotmpl",
    },
    initializationOptions = {
        workspaces = {
            paths = {
                defaults = {
                    vim.env.XDG_CONFIG_HOME .. "/fish",
                    vim.env.HOMEBREW_PREFIX .. "/share/fish/",
                },
            },
        },
    },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        if client.server_capabilities then
            client.server_capabilities.documentHighlightProvider = false
        end
    end,
    single_file_support = true,
}
