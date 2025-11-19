---@type vim.lsp.Config
return {
    cmd = { "fish-lsp", "start" },
    cmd_env = {
        fish_lsp_commit_characters = "'\t'",
        fish_lsp_show_client_popups = false,
    },
    filetypes = {
        "fish",
        "fish.gotmpl",
    },
    single_file_support = true,
}
