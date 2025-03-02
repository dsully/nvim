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
            diagnostics = {
                ignored = {},
            },
            formatting = {
                command = { "alejandra", "--" },
            },
            nix = {
                maxMemoryMB = 2048,
            },
            flake = {
                autoArchive = false,
                autoEvalImputs = true,
                nixpkgsInputName = "nixpkgs",
            },
        },
    },
}
