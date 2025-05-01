---@type vim.lsp.Config
return {
    cmd = {
        "emmylua_ls",
    },
    filetypes = { "lua" },
    root_dir = function(_bufnr, on_dir)
        if vim.uv.fs_stat(".emmyrc.json") then
            on_dir(vim.uv.cwd())
        end
    end,
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
