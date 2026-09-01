---@type vim.lsp.Config
return {
    cmd = { "zuban", "server" },
    filetypes = { "python" },
    init_options = {
        diagnosticMode = "workspace",
        disableLanguageServices = true,
        inlayHintMode = "off",
        typeCheckingMode = "mypy",
    },
    root_markers = {
        "pyproject.toml",
    },
    single_file_support = true,
}
