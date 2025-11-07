---@type vim.lsp.Config
return {
    cmd = { "crates-lsp" },
    filetypes = { "toml" },
    root_markers = {
        "Cargo.toml",
        ".git",
    },
    single_file_support = true,
}
