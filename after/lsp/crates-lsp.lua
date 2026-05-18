---@type vim.lsp.Config
return {
    cmd = { "crates-lsp" },
    filetypes = { "toml" },
    init_options = {
        -- needs_update_severity = 1, -- Report necessary updates as ERRORs
        diagnostics = false,
    },
    root_markers = {
        "Cargo.toml",
        ".git",
    },
    single_file_support = true,
}
