---@type vim.lsp.Config
return {
    cmd = { "nil" },
    filetypes = {
        "nix",
    },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        if client.server_capabilities then
            client.server_capabilities.renameProvider = nil
        end
    end,
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
                    autoEvalInputs = true,
                },
            },
        },
    },
    single_file_support = true,
}
