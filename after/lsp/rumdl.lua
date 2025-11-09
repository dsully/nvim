---@type vim.lsp.Config
return {
    cmd = { "rumdl", "server" },
    filetypes = {
        "markdown",
    },
    root_markers = {
        ".git",
    },
    single_file_support = true,
}
