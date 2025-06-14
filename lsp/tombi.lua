---@type vim.lsp.Config
return {
    cmd = { "tombi", "lsp" },
    filetypes = { "toml", "toml.pyproject" },
    single_file_support = true,
}
