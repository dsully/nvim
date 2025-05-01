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
    init_options = {
        settings = {
            ruff = {
                path = vim.fn.executable("ruff"),
            },
        },
    },
    single_file_support = true,
}
