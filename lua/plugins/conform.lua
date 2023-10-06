return {
    "stevearc/conform.nvim",
    config = function()
        local add_formatter_args = require("conform.util").add_formatter_args
        local root_file = require("conform.util").root_file

        add_formatter_args(require("conform.formatters.markdownlint"), {
            string.format("--config=%s/markdownlint/config.yaml", vim.env.XDG_CONFIG_HOME),
        })

        add_formatter_args(require("conform.formatters.shfmt"), { "-i", "4", "-ci", "-s" })

        -- This needs to be dynamic and not just at Neovim startup time.
        require("conform.formatters.black").args = function()
            return vim.tbl_flatten({
                require("plugins.lsp.python").black_args(),
                {
                    "--stdin-filename",
                    "$FILENAME",
                    "--quiet",
                    "-",
                },
            })
        end

        require("conform.formatters.black").cwd = root_file({ "pyproject.toml", "setup.cfg" })

        local black = { "blackd", "black" }
        local prettier = { "prettierd", "prettier" }
        local shell = { "shellcheck", "shellharden", "shfmt" }

        require("conform").setup({
            formatters_by_ft = {
                bash = shell,
                c = { "clang-format" },
                caddy = { "caddy" },
                cpp = { "clang-format" },
                css = { prettier },
                fish = { "fish_indent" },
                go = { "goimports", "delve" },
                graphql = { prettier },
                html = { prettier },
                just = { "just" },
                lua = { "stylua" },
                markdown = { "markdownlint" },
                python = { black },
                sh = shell,
                zsh = shell,
            },
            formatters = {
                blackd = {
                    command = "blackd-client",
                    args = function()
                        return require("plugins.lsp.python").black_args()
                    end,
                    cwd = require("conform.util").root_file({
                        "setup.cfg",
                        "pyproject.toml",
                    }),
                    stdin = true,
                },
                caddy = {
                    command = "caddy",
                    args = { "fmt", "-" },
                    cwd = root_file({ "Caddyfile" }),
                    stdin = true,
                },
            },
        })
    end,
    keys = {
        {
            "<space>f",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            mode = "n",
            desc = "󰛗 Format Buffer",
        },
    },
}
