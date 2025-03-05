---@type vim.lsp.Config
return {
    cmd = { "nil" },
    -- cmd = { "nix-shell", "-p", "nil", "--run", "nil" },
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
}
