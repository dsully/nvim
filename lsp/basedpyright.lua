vim.lsp.config.basedpyright = {
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
                reportUnreachable = true,
                typeCheckingMode = "off", -- standard
                useLibraryCodeForTypes = true,
            },
            disableOrganizeImports = true,
        },
    },
    single_file_support = true,
}
