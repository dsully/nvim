vim.lsp.config.lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    on_attach = function(...)
        require("lazydev.buf").on_attach(...)
    end,
    settings = {
        Lua = {
            codeLens = {
                enable = true,
            },
            completion = {
                autoRequire = false,
                callSnippet = "Replace",
                keywordSnippet = "Both",
                workspaceWord = true,
            },
            diagnostics = {
                globals = {
                    "LazyVim",
                    "Snacks",
                    "bit",
                    "colors",
                    "defaults",
                    "describe",
                    "ev",
                    "hl",
                    "it",
                    "keys",
                    "math",
                    "ns",
                    "package",
                    "require",
                    "vim",
                },
                unusedLocalExclude = {
                    "_*",
                },
            },
            doc = {
                privateName = { "^_" },
            },
            format = {
                enable = false,
            },
            hint = {
                arrayIndex = "Disable",
                enable = true,
                paramName = "Disable",
                paramType = true,
                semicolon = "Disable",
                setType = true,
            },
            hover = {
                expandAlias = false,
            },
            telemetry = {
                enable = false,
            },
            type = {
                castNumberToInteger = true,
                inferParamType = true,
            },
        },
    },
    root_markers = {
        ".luacheckrc",
        ".luarc.json",
        ".luarc.jsonc",
        ".stylua.toml",
        "lazy-lock.json",
        "selene.toml",
        "selene.yml",
        "stylua.toml",
    },
    single_file_support = true,
}
