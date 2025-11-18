---@type vim.lsp.Config
return {
    cmd = { "pytest-language-server" },
    filetypes = {
        "python",
    },
    root_markers = {
        "pyproject.toml",
        "pytest.ini",
        "requirements.txt",
        "setup.py",
    },
    single_file_support = true,
}
