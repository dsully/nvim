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
        bash = { "shellharden", "shfmt" },
        bzl = { "buildifier" },
        caddy = { "caddy" },
        direnv = { "shellharden", "shfmt" },
        fish = { "fish_indent" },
        go = { "goimports", "gofumpt" },
        javascript = { "biome" },
        just = { "just" },
        lua = { "stylua" },
        markdown = { "markdownlint" },
        rust = {},
        sh = { "shellharden", "shfmt" },
        toml = { "taplo" },
        typescript = { "biome" },
    },

    linters = {
        fish = { "fish" },
        ghaction = { "actionlint" },
        gitcommit = { "write_good" },
        go = { "revive" },
        htmldjango = { "curlylint" },
        jinja = { "curlylint" },
        markdown = { "markdownlint", "write_good" },
        protobuf = { "protolint" },
        rst = { "rstcheck", "write_good" },
        text = { "write_good" },
        yaml = { "yamllint" },
    },

    tools = {
        "actionlint",
        "biome",
        "curlylint",
        "gitui",
        "gofumpt",
        "goimports",
        "markdownlint",
        "protolint",
        "revive",
        "rstcheck",
        "shellharden",
        "shfmt",
        "stylua",
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

    -- Nordic: blue, intense_blue, none
    blue = { base = "#81a1c1", bright = "#5e81ac", dim = "#668aab" },

    -- Nordic: black, bright_black, dark_black
    black = { base = "#3b4252", bright = "#434c5e", dim = "#2e3440" },

    -- Nordic: cyan, bright_cyan, none
    cyan = { base = "#8fbcbb", bright = "#88c0d0", dim = "#69a7ba" },

    -- Nordic: white, bright_white, dark_white
    white = { base = "#e5e9f0", bright = "#eceff4", dim = "#d8dee9" },

    -- Nordic: gray, grayish, dark_black_alt
    gray = { base = "#4c566a", bright = "#667084", dim = "#2b303b" },
}

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
