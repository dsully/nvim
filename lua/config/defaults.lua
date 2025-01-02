local copilot = " "

local M = {
    code_actions = {
        "",
        "quickfix",
        -- "refactor",
        -- "refactor.extract",
        -- "refactor.inline",
        "refactor.rewrite",
        "source",
        "source.fixAll",
        "source.organizeImports",
    },

    files = {
        ignored_patterns = {
            "%.DS_Store",
            "%.gz",
            "%.jpeg",
            "%.jpg",
            "%.lock",
            "%.png",
            "%.yarn/.*",
            "^.direnv/.*",
            "^.git/",
            "^.venv/.*",
            "^__pypackages__/.*",
            "^lazy-lock.json",
            "^site-packages/",
            "^target/",
            "^venv/.*",
            "node%_modules/.*",
        },
    },

    -- Filetypes that should be formatted on save.
    formatting = {
        file_types = {
            bash = { "shellharden", "shfmt" },
            bzl = { "buildifier" },
            caddy = { "caddy" },
            css = { "biome" },
            direnv = { "shellharden", "shfmt" },
            fish = { "fish_indent" },
            go = { "goimports", "gofumpt" },
            graphql = { "biome" },
            javascript = { "biome" },
            json = { "biome" },
            jsonc = { "biome" },
            jsx = { "biome" },
            just = { "just" },
            lua = { "stylua" },
            markdown = { "markdownlint-cli2" },
            python = { "ruff_organize_imports", "ruff_format", "ruff_fix" },
            rust = {},
            sh = { "shellharden", "shfmt" },
            toml = { "taplo" },
            tsx = { "biome" },
            typescript = { "biome" },
            xml = { "xmlformatter" },
        },
        on_save = {
            "bash",
            "caddy",
            "direnv",
            "fish",
            "go",
            "just",
            "lua",
            "rust",
            "toml",
        },
    },

    linters = {
        css = { "stylelint" },
        fish = { "fish" },
        ghaction = { "actionlint" },
        gitcommit = { "commitlint", "write_good" },
        go = { "revive" },
        htmldjango = { "curlylint" },
        jinja = { "curlylint" },
        markdown = { "markdownlint-cli2", "write_good" },
        protobuf = { "protolint" },
        rst = { "rstcheck", "write_good" },
        text = { "write_good" },
        yaml = { "yamllint" },
    },

    lsp = {
        rust = {
            bacon = os.getenv("BACON") or false,
        },

        servers = {
            "basedpyright",
            "bashls",
            "cssls",
            "dockerls",
            "fish_lsp",
            "gopls",
            "harper",
            "html",
            "jsonls",
            "lemminx",
            "lua_ls",
            "marksman",
            "red_knot",
            "ruff",
            "ts_ls",
            "yamlls",
            "zls",
        },
    },

    tools = {
        "css-lsp",
        "curlylint",
        "goimports",
        "html-lsp",
        "json-lsp",
        "lemminx",
        "marksman",
        "rstcheck",
        "xmlformatter",
        "yamllint",
        "zls",
    },

    icons = {
        actions = {
            close = "󰅖 ",
            close_box = "󰅗 ",
            close_hexagon = "󰅜 ",
            close_outline = "󰅚 ",
            close_round = "󰅙 ",
        },
        diagnostics = {
            error = "󰅚",
            warn = "󰀪",
            info = "",
            hint = "󰌶",
            debug = "",
            trace = "",
        },
        fold = {
            open = " ",
            closed = "",
        },
        git = {
            add = " ", -- '',
            mod = " ",
            remove = " ", -- '',
            ignore = " ",
            rename = " ",
            untracked = " ",
            ignored = " ",
            unstaged = "󰄱 ",
            staged = " ",
            conflict = " ",
            diff = " ",
            repo = " ",
            logo = "󰊢 ",
            branch = " ",
        },
        menu = {
            actions = {
                outline = {
                    left = "󰨂",
                    right = "󰨃",
                    up = "󰚷",
                    down = "󰚶",
                    swap = "󰩥",
                    filter = "󱃦",
                },
                filled = {
                    up = "󰍠",
                    down = "󰍝",
                    left = "󰍞",
                    right = "󰍟",
                    swap = "󰩤",
                    filter = "󱃥 ",
                },
            },
            hamburger = "󰍜 ",
            hamburger_open = "󰮫 ",
        },
        misc = {
            arrow_right = "",
            block = "▌",
            bookmark = " ",
            bug = " ", --  '󰠭'
            calendar = " ",
            caret_right = "",
            check = "󰄬 ",
            chevron_right = " ",
            circle = " ",
            circle_filled = " ",
            circle_filled_large = "⬤",
            circle_slash = " ",
            clock = " ",
            code = " ",
            comment = "󰅺 ",
            copilot = copilot,
            dashboard = " ",
            datetime = "󱛡 ",
            double_chevron_right = "»",
            down = "⇣",
            ellipse_dbl = "",
            ellipsis = "…",
            exit = "󰗼 ",
            fire = " ",
            gear = " ",
            git = " ",
            github = "󰊤 ",
            history = "󰄉 ",
            hook = "󰛢",
            hook_disabled = "󰛣 ",
            indent = "Ξ",
            kebab = "",
            lightbulb = "󰌶 ",
            line = "", -- 'ℓ'
            list = " ",
            lock = "",
            modified = "●",
            newline = "",
            note = "󰎞 ",
            package = " ",
            pencil = " ", -- '󰏫',
            plus = " ",
            project = " ",
            question = " ",
            robot = "󰚩 ",
            search = "󰍉 ",
            shaded_lock = " ",
            sign_in = " ",
            tab = "⇥",
            table = " ",
            telescope = " ",
            tools = " ",
            up = "⇡",
        },
        separators = {
            angle_quote = {
                left = "«",
                right = "»",
            },
            chevron = {
                left = "",
                right = "",
                down = "",
            },
            circle = {
                left = "",
                right = "",
            },
            arrow = {
                left = "",
                right = "",
            },
            slant = {
                left = "",
                right = "",
            },
            bar = {
                left = "⎸",
                right = "⎹",
            },
        },
        lsp = {
            Class = "",
            Color = "",
            Constant = "󰏿",
            Constructor = "",
            Enum = "",
            EnumMember = "",
            Event = "",
            Field = "󰇽",
            File = "󰉋",
            Folder = "󰉋",
            Function = "󰊕",
            Interface = "",
            Keyword = "󰌋",
            Method = "",
            Module = "",
            Namespace = "󰦮",
            Null = "",
            Number = "󰎠",
            Object = "",
            Operator = "󰆕",
            Package = "",
            Property = "󰜢",
            Reference = "",
            Snippet = "",
            String = "",
            Struct = "󰆼",
            Text = "",
            TypeParameter = "󰅲",
            Unit = "",
            Value = "",
            Variable = "󰀫",
            Version = "󱘗", -- crates.nvim lsp completion type.
        },
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
            "",
            "DressingInput",
            "DressingSelect",
            "alpha",
            "bigfile",
            "checkhealth",
            "copilot-chat",
            "crates.nvim",
            "git",
            "gitrebase",
            "lazy",
            "log",
            "lspinfo",
            "mason",
            "noice",
            "notify",
            "oil",
            "qf",
            "snacks_dashboard",
            "snacks_input",
            "snacks_notif",
            "trouble",
            "vim",
        },
        lsp = {
            "copilot",
            "llm-ls",
            "sonarlint.nvim",
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
            "basedpyright",
            "copilot",
            "ltex",
            "pylance",
            "pyright",
            "sonarlint.nvim",
        },
    },

    root_patterns = {
        ".chezmoiroot",
        ".luacheckrc",
        ".luarc.json",
        ".luarc.jsonc",
        ".stylua.toml",
        "Cargo.toml",
        "build.zig",
        "configure",
        "fish_variables",
        "go.mod",
        "package.json",
        "pyproject.toml",
        "requirements.txt",
        "ruff.toml",
        "selene.toml",
        "selene.yml",
        "setup.cfg",
        "setup.py",
        "stylua.toml",
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

    treesitter = {
        install = {
            "bash",
            "c",
            "caddyfile",
            "cmake",
            "comment",
            "cpp",
            "css",
            "csv",
            "diff",
            "dockerfile",
            "dtd",
            "editorconfig",
            "fish",
            "ghostty",
            "git_config",
            "git_rebase",
            "gitattributes",
            "gitcommit",
            "gitignore",
            "go",
            "gomod",
            "gosum",
            "gotmpl",
            "gowork",
            "graphql",
            "groovy",
            "hcl",
            "html",
            "htmldjango",
            "http",
            "ini",
            "java",
            "javascript",
            "jinja2",
            "jsdoc",
            "json",
            "json5",
            "jsonc",
            "just",
            "kdl",
            "kotlin",
            "lua",
            "luadoc",
            "luap",
            "make",
            "markdown",
            "markdown_inline",
            "mermaid",
            "ninja",
            "nix",
            "passwd",
            "pem",
            "printf",
            "properties",
            "proto",
            "python",
            "query",
            "regex",
            "requirements",
            "ron",
            "rst",
            "ruby",
            "rust",
            "ssh_config",
            "strace",
            "swift",
            "teal",
            "terraform",
            "textproto",
            "toml",
            "tsv",
            "tsx",
            "typescript",
            "udev",
            "vim",
            "vimdoc",
            "xml",
            "yaml",
            "zig",
        },
    },

    ui = {
        border = {
            name = "single",
            chars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        float = {
            border = "single",
            relative = "editor",
            style = "minimal",
            height = 0.75,
            width = 0.8,
        },
    },
}

return M
