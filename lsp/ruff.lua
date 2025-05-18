---@type vim.lsp.Config
return {
    cmd = { "ruff", "server" },
    filetypes = {
        "python",
    },
    root_markers = {
        ".ruff.toml",
        "pyproject.toml",
        "requirements.txt",
        "ruff.toml",
        "setup.py",
    },
    single_file_support = true,
}
