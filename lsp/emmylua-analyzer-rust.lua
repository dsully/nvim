---@type vim.lsp.Config
return {
    cmd = {
        "emmylua_ls",
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
    settings = {
        Lua = {
            diagnostics = {
                disable = {
                    "missing-fields",
                    "type-not-found",
                    "undefined-field",
                },
                globals = {
                    "Snacks",
                    "bit",
                    "colors",
                    "defaults",
                    "ev",
                    "hl",
                    "keys",
                    "ns",
                    "package",
                    "require",
                    "vim",
                },
                unusedLocalExclude = {
                    "_*",
                },
            },
            runtime = {
                version = "LuaJIT",
            },
            workspace = {
                library = {
                    "$VIMRUNTIME",
                    "$XDG_DATA_HOME/nvim/lazy/",
                },
                workspaceRoots = {
                    "lua",
                },
            },
        },
    },
    single_file_support = true,
}
