---@type vim.lsp.Config
return {
    cmd = { "ruff", "server" },
    filetypes = {
        "python",
    },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        if client.server_capabilities then
            -- client.server_capabilities.codeActionProvider = nil

            client.server_capabilities.hoverProvider = nil
            client.server_capabilities.notebookDocumentSync = nil
        end
    end,
    root_markers = {
        ".ruff.toml",
        "pyproject.toml",
        "requirements.txt",
        "ruff.toml",
        "setup.py",
    },
    single_file_support = true,
}
