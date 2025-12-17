---@type vim.lsp.Config
return {
    cmd = { "pytest-language-server" },
    filetypes = {
        "python",
    },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        if client.server_capabilities then
            client.server_capabilities.hoverProvider = nil
        end
    end,
    root_markers = {
        "pyproject.toml",
        "pytest.ini",
        "requirements.txt",
        "setup.py",
    },
    single_file_support = true,
}
