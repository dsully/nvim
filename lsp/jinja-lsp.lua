---@type vim.lsp.Config
return {
    cmd = { "jinja-lsp" },
    filetypes = { "jinja2" },
    init_options = {
        templates = "./templates",
        backend = { "./src" },
    },
    root_markers = { ".git" },
    single_file_support = true,
}
