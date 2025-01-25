---@type vim.lsp.Config
return {
    cmd = { "ruff", "server" },
    filetypes = { "pyproject", "pyproject.toml", "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml" },
    single_file_support = true,
}
