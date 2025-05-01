---@type vim.lsp.Config
return {
    cmd = {
        vim.env.HOME .. "/src/rust/emmylua-analyzer-rust/target/release/emmylua_ls",
    },
    filetypes = { "lua" },
    root_markers = {
        ".emmyrc.json",
        ".luarc.json",
        ".luarc.jsonc",
        ".stylua.toml",
        "lazy-lock.json",
        "selene.toml",
        "selene.yml",
        "stylua.toml",
        "lua/",
    },
    single_file_support = true,
}
