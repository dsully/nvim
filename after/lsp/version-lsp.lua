---@type vim.lsp.Config
return {
    cmd = { "version-lsp" },
    filetypes = {
        "gomod",
        -- "json",
        -- "jsonc",
        "toml",
        -- "yaml"
    },
    root_markers = {
        ".git",
    },
    single_file_support = true,
}
