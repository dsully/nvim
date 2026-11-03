---@type vim.lsp.Config
return {
    cmd = { "nil" },
    filetypes = {
        "nix",
    },
    root_markers = {
        "default.nix",
        "flake.nix",
        "shell.nix",
    },
    ---@type lspconfig.settings.nil_ls
    settings = {
        ["nil"] = {
            formatting = {
                command = { "alejandra", "--" },
            },
            nix = {
                flake = {
                    autoArchive = false,
                    autoEvalInputs = false,
                },
            },
        },
    },
    single_file_support = true,
}
