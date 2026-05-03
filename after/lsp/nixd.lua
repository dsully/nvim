---@type vim.lsp.Config
return {
    cmd = { "nixd" },
    filetypes = {
        "nix",
    },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        if client.server_capabilities then
            client.server_capabilities.definitionProvider = false
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentHighlightProvider = false
            client.server_capabilities.documentLinkProvider = { resolveProvider = false }
            client.server_capabilities.documentRangeFormattingProvider = false
            client.server_capabilities.documentSymbolProvider = false
            client.server_capabilities.hoverProvider = nil
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
                    expr = string.format("(builtins.getFlake (toString ./.)).darwinConfigurations.%s.options", vim.uv.os_gethostname()),
                },
            } or {
                nixos = {
                    expr = string.format("(builtins.getFlake (toString ./.)).nixosConfigurations.%s.options", vim.uv.os_gethostname()),
                },
            }),
        },
    },
    single_file_support = true,
}
