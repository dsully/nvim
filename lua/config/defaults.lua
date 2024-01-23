local M = {
    ai_file_types = {
        "bash",
        "c",
        "cpp",
        "fish",
        "go",
        "html",
        "java",
        "javascript",
        "just",
        "lua",
        "python",
        "rust",
        "sh",
        "typescript",
        "zsh",
    },

    cmp = {
        backend = "nvim-cmp",
        priorities = {
            Field = 11,
            Property = 11,
            Constant = 10,
            Enum = 10,
            EnumMember = 10,
            Event = 10,
            Function = 10,
            Method = 10,
            Operator = 10,
            Reference = 10,
            Struct = 10,
            Variable = 12,
            File = 8,
            Folder = 8,
            Class = 5,
            Color = 5,
            Module = 5,
            Keyword = 2,
            Constructor = 1,
            Interface = 1,
            Snippet = 0,
            Text = 1,
            TypeParameter = 1,
            Unit = 1,
            Value = 1,
        },
        menu = {},
        symbols = {
            buffer = " [Buffer]",
            luasnip = "󰢱 [LuaSnip]",
            nvim_lsp = " [LSP]",
        },
    },

    formatters = {
        bash = { "shellcheck", "shellharden", "shfmt" },
        bzl = { "buildifier" },
        c = { "clang-format" },
        caddy = { "caddy" },
        cpp = { "clang-format" },
        css = { "prettier" },
        fish = { "fish_indent" },
        go = { "goimports", "gofumpt", "delve" },
        graphql = { "prettier" },
        html = { "prettier" },
        just = { "just" },
        lua = { "stylua" },
        markdown = { "markdownlint" },
        sh = { "shellcheck", "shellharden", "shfmt" },
        zsh = { "shellcheck", "shellharden", "shfmt" },
    },

    -- Diagnostic symbols in the gutter.
    icons = {
        error = "󰅚 ",
        warn = "󰀪 ",
        info = " ",
        hint = "󰌶 ",
    },

    -- Various buffer and file types that should be ignored.
    ignored = {
        buffer_types = {
            "Trouble",
            "gitcommit",
            "help",
            "nofile",
            "quickfix",
            "terminal",
            "trouble",
        },
        file_types = {
            "",
            "Codewindow",
            "DressingInput",
            "TelescopePrompt",
            "TelescopeResults",
            "Trouble",
            "alpha",
            "chatgpt",
            "chatgpt-input",
            "checkhealth",
            "cmp_menu",
            "git",
            "gitrebase",
            "glowpreview",
            "keymenu",
            "lazy",
            "log",
            "lspinfo",
            "mason",
            "noice",
            "notify",
            "qf",
            "trouble",
            "tsplayground",
            "vim",
        },
        lsp = {
            "copilot",
            "llm-ls",
            "typos_lsp",
        },
        paths = {
            "~/.cache",
            "~/.cargo",
            "~/.local/state",
            "~/.rustup",
            tostring(vim.fn.stdpath("data")),
            tostring(vim.fn.stdpath("state")),
        },
        progress = {
            "copilot",
            "lua_ls",
            "ltex",
            "pylance",
            "pyright",
            "ruff_lsp",
        },
    },

    lazyfile = { { "BufReadPost", "BufNewFile", "BufWritePre" } },

    statusline = {
        modes = {
            ["n"] = "N",
            ["no"] = "N",
            ["nov"] = "N",
            ["noV"] = "N",
            ["no"] = "N",
            ["niI"] = "N",
            ["niR"] = "N",
            ["niV"] = "N",
            ["v"] = "V",
            ["V"] = "V",
            [""] = "V",
            ["s"] = "S",
            ["S"] = "S",
            [""] = "S",
            ["i"] = "I",
            ["ic"] = "I",
            ["ix"] = "I",
            ["R"] = "R",
            ["Rc"] = "R",
            ["Rv"] = "R",
            ["Rx"] = "R",
            ["r"] = "R",
            ["rm"] = "R",
            ["r?"] = "R",
            ["c"] = "C",
            ["cv"] = "C",
            ["ce"] = "C",
            ["!"] = "T",
            ["t"] = "T",
            ["nt"] = "T",
        },

        wordcount = {
            markdown = true,
            text = true,
            vimwiki = true,
        },
    },
}

M.colors = {
    -- Slightly tweaked to be more like nordic.nvim.
    red = { base = "#bf616a", bright = "#d06f79", dim = "#a54e56" },
    orange = { base = "#d08770", bright = "#d89079", dim = "#b46950" },
    green = { base = "#a3be8c", bright = "#b1d196", dim = "#8aa872" },
    yellow = { base = "#ebcb8b", bright = "#f0d399", dim = "#d9b263" },
    magenta = { base = "#b48ead", bright = "#c895bf", dim = "#9d7495" },
    pink = { base = "#bf88bc", bright = "#d092ce", dim = "#a96ca5" },

    -- Nordic: blue, intense_blue, none
    blue = { base = "#81a1c1", bright = "#5e81ac", dim = "#668aab" },

    -- Nordic: black, bright_black, dark_black
    black = { base = "#3b4252", bright = "#434c5e", dim = "#2e3440" },

    -- Nordic: cyan, bright_cyan, none
    cyan = { base = "#8fbcbb", bright = "#88c0d0", dim = "#69a7ba" },

    -- Nordic: white, bright_white, dark_white
    white = { base = "#e5e9f0", bright = "#eceff4", dim = "#d8dee9" },

    -- Noridc: gray, grayish, dark_black_alt
    gray = { base = "#4c566a", bright = "#667084", dim = "#2b303b" },
}

M.colors.comment = M.colors.gray.bright
M.colors.bg0 = M.colors.black.base -- Dark bg (status line and float)
M.colors.bg1 = M.colors.black.dim -- Default bg

M.colors.bg2 = "#39404f" -- Lighter bg (color column folds)
M.colors.bg3 = "#444c5e" -- Lighter bg (cursor line)
M.colors.bg4 = M.colors.black.bright -- Conceal, border fg

M.colors.fg0 = "#c7cdd9" -- Lighter fg
M.colors.fg1 = M.colors.white.dim -- Default fg: white.base
M.colors.fg2 = M.colors.white.base -- Darker fg (status line): cyan.bright
M.colors.fg3 = M.colors.gray.base -- Darker fg (line numbers, fold columns)

M.colors.sel0 = "#3e4a5b" -- Pop-up bg, visual selection bg
M.colors.sel1 = "#4f6074" -- Pop-up selection bg, search bg

-- Keymap helpers.
M.cmd = function(cmd)
    return "<cmd>" .. cmd .. "<CR>"
end

M.cmd_alt = function(cmd)
    return ":" .. cmd .. "<CR>"
end

M.lua = function(cmd)
    return "<cmd>lua " .. cmd .. "<CR>"
end

return M
