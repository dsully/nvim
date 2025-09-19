---@type vim.lsp.Config
return {
    cmd = { "nixd" },
    filetypes = {
        "nix",
    },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        if client.server_capabilities then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentHighlightProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end
    end,
    root_markers = {
        "default.nix",
        "devshell.nix",
        "flake.nix",
        "shell.nix",
    },
    settings = {
        nixd = {
            flake = {
                checkOnSave = true,
            },
            formatting = {
                command = { "alejandra" },
            },
            nixpkgs = {
                expr = "import <nixpkgs> { }",
            },
            options = vim.tbl_extend("force", {
                enable = true,
            }, vim.fn.has("mac") and {
                ["nix-darwin"] = {
                    expr = string.format("(builtins.getFlake (toString ./.)).darwinConfigurations.%s.options", vim.fn.hostname()),
                },
            } or {
                nixos = {
                    expr = string.format("(builtins.getFlake (toString ./.)).nixosConfigurations.%s.options", vim.fn.hostname()),
                },
            }),
        },
    },
    single_file_support = true,
}
