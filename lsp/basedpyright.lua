---@type vim.lsp.Config
return {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        --
        -- Use treesitter highlighting, as it supports injections.
        client.server_capabilities.semanticTokensProvider = nil
    end,
    root_markers = {
        "Pipfile",
        "pyproject.toml",
        "pyrightconfig.json",
        "requirements.txt",
        "setup.cfg",
        "setup.py",
    },
    settings = {
        basedpyright = {
            analysis = {
                autoImportCompletions = false,
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                reportMissingTypeStubs = false,
                reportUndefinedVariable = "none", -- covered by ruff
                reportUnreachable = "none",
                reportUnusedImport = "none", -- covered by ruff
                typeCheckingMode = "basic", -- standard
                useLibraryCodeForTypes = true,
            },
            disableOrganizeImports = true,
        },
    },
    single_file_support = true,
}
