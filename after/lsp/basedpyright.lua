---@type vim.lsp.Config
return {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    ---@param client vim.lsp.Client
    on_attach = function(client)
        --
        -- Use treesitter highlighting, as it supports injections.
        if client.server_capabilities then
            client.server_capabilities.semanticTokensProvider = nil
        end
    end,
    root_dir = function(_bufnr, on_dir)
        -- Make basePyright the default.
        if vim.env.SITH == nil and vim.env.JEDI == nil then
            on_dir(nvim.file.cwd())
        end
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
                autoImportCompletions = true,
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                reportMissingTypeStubs = false,
                reportUndefinedVariable = "off", -- covered by ruff
                reportUnreachable = "off",
                reportUnusedImport = "off", -- covered by ruff
                typeCheckingMode = "off", -- standard
                useLibraryCodeForTypes = false,
            },
            disableOrganizeImports = true,
        },
    },
    single_file_support = true,
}
