---@type vim.lsp.Config
return {
    cmd = { "sith-lsp" },
    filetypes = {
        "python",
    },
    root_markers = {
        "pyproject.toml",
        "requirements.txt",
    },
    settings = {
        ruff = {
            enable = true,
            format = { enable = true },
            lint = { enable = true },
        },
    },
    single_file_support = true,
}
