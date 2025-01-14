---@type vim.lsp.Config
return {
    cmd = { "marksman", "server" },
    filetypes = { "markdown", "markdown.mdx" },
    root_markers = {
        ".marksman.toml",
    },
    single_file_support = true,
}
