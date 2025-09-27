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
    settings = {
        ["nil"] = {
            formatting = {
                command = { "alejandra", "--" },
            },
            nix = {
                flake = {
                    autoArchive = false,
                    autoEvalImputs = true,
                },
            },
        },
    },
    single_file_support = true,
}
