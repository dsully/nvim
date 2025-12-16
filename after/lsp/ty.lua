---@type vim.lsp.Config
return {
    cmd = {
        "ty",
        "server",
    },
    filetypes = { "python" },
    -- init_options = {
    --     logFile = nvim.file.xdg_cache("ty.log"),
    -- },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        if client.server_capabilities then
            -- client.server_capabilities.completionProvider = nil
            --
            -- client.server_capabilities.documentHighlightProvider = nil
            client.server_capabilities.hoverProvider = nil
            -- client.server_capabilities.inlayHintProvider = nil
            -- -- client.server_capabilities.semanticTokensProvider = nil
            -- -- client.server_capabilities.typeDefinitionProvider = nil
            --
            client.server_capabilities.declarationProvider = nil
            client.server_capabilities.definitionProvider = nil
            client.server_capabilities.referencesProvider = nil
            client.server_capabilities.typeDefinitionProvider = nil
        end
    end,
    -- root_dir = function(_bufnr, _on_dir)
    --     --
    -- end,
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
