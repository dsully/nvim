---@type vim.lsp.Config
return {
    cmd = { "tombi", "lsp" },
    filetypes = { "toml" },
    root_markers = {
        "pyproject.toml",
        "tombi.toml",
    },
    single_file_support = true,
}
