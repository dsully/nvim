---@type vim.lsp.Config
return {
    cmd = {
        "red_knot",
        "server",
    },
    filetypes = { "python" },
    root_markers = {
        "Pipfile",
        "pyproject.toml",
        "pyrightconfig.json",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
    },
    single_file_support = true,
    trace = "messages",
}
