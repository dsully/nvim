---@type vim.lsp.Config
return {
    cmd = { "rust_markdown_lsp" },
    filetypes = {
        "markdown",
        "markdown.mdx",
    },
    root_markers = {
        "rust_markdown_lsp.toml",
        ".git",
    },
    single_file_support = true,
}
