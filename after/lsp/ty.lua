---@type vim.lsp.Config
return {
    cmd = {
        "ty",
        "server",
    },
    filetypes = { "python" },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        if client.server_capabilities then
            client.server_capabilities.hoverProvider = false
        end
    end,
    root_markers = {
        "Pipfile",
        "pyproject.toml",
        "pyrightconfig.json",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
    },
    settings = {
        ty = {
            diagnosticMode = "workspace",
        },
    },
    single_file_support = true,
}
