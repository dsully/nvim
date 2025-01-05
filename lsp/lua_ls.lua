---@type vim.lsp.Config
return {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    --- @param client vim.lsp.Client
    on_init = function(client)
        -- Use stylua via conform.nvim
        client.server_capabilities.documentFormattingProvider = nil
        client.server_capabilities.documentRangeFormattingProvider = nil
    end,
    settings = {
        ---@type LuaLanguageServerSettings
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
                disable = {
                    "inject-field",
                    "missing-fields",
                    "missing-parameter",
                },
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
                expandAlias = true,
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
        "lua/",
    },
    single_file_support = true,
}
