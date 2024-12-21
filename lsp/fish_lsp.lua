return {
    cmd = { "fish-lsp", "start" },
    cmd_env = { fish_lsp_show_client_popups = false },
    filetypes = { "fish" },
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

    single_file_support = true,
}
