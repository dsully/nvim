---@type vim.lsp.Config
return {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
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
