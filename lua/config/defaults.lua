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

    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },

    cmp = {
        backend = "nvim-cmp",
        kind = {
            calc = "󰃬",
            fish = "󰌋",
        },
        menu = {
            async_path = " [Path]",
            buffer = " [Buffer]",
            calc = "󰃬 [Calc]",
            cmdline = "󰘳 [Command]",
            crates = " [󱘗 Crates]",
            copilot = " [Copilot]",
            env = " [ENV]",
            fish = "󰈺 [Fish]",
            luasnip = " [LuaSnip]",
            snippets = " [Snippets]",
            nvim_lsp = " [LSP]",
            path = " [Path]",
        },
        symbols = {
            Copilot = "",
            Snippet = "",
            Version = "󱘗", -- crates.nvim lsp completion type.
        },
    },

    formatters = {
        filetypes = {
            "bash",
            "bzl",
            "caddyfile",
            "css",
            "dockerfile",
            "fish",
            "go",
            "html",
            "javascript",
            "javascriptreact",
            "jinja",
            "json",
            "jsonc",
            "lua",
            "markdown",
            "rust",
            "sh",
            "sql",
            "toml",
            "toml.pyproject",
            "typescript",
            "typescriptreact",
            "zsh",
        },
    },

    linters = {
        bash = { "shellcheck" },
        fish = { "fish" },
        ghaction = { "actionlint" },
        gitcommit = { "gitlint", "write_good" },
        go = { "revive" },
        htmldjango = { "curlylint" },
        jinja = { "curlylint" },
        markdown = { "markdownlint", "write_good" },
        protobuf = { "protolint" },
        rst = { "rstcheck", "write_good" },
        sh = { "shellcheck" },
        text = { "write_good" },
        yaml = { "yamllint" },
    },

    tools = {
        "actionlint",
        "buildifier",
        "codelldb",
        "curlylint",
        "dprint",
        "gitlint",
        "gitui",
        "gofumpt",
        "jdtls",
        "markdownlint",
        "protolint",
        "revive",
        "rstcheck",
        "shellharden",
        "shellharden",
        "shfmt",
        "write-good",
        "yamllint",
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
            "ltex",
            "pylance",
            "pyright",
            "ruff_lsp",
        },
    },

    root_patterns = {
        ".chezmoiroot",
        ".neoconf.json",
        ".neoconf.jsonc",
        ".stylua.toml",
        "configure",
        "package.json",
        "pyproject.toml",
        "requirements.txt",
        "ruff.toml",
        "selene.toml",
        "setup.cfg",
        "setup.py",
        "stylua.toml",
        "Cargo.toml",
    },

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
