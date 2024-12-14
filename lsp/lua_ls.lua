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
                -- disable = {
                --     "missing-fields",
                -- },
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
        ".luarc.json",
        ".luarc.jsonc",
        ".luacheckrc",
        ".stylua.toml",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
        "lua/",
    },
    single_file_support = true,
}
