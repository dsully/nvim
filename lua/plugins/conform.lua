return {
    "stevearc/conform.nvim",
    config = function()
        require("conform.formatters.black").args = require("plugins.lsp.python").black_args()

        require("conform.formatters.markdownlint").args = function()
            return {
                string.format("--config=%s/markdownlint/config.yaml", vim.env.XDG_CONFIG_HOME),
                "--fix",
                "$FILENAME",
            }
        end

        require("conform.formatters.shfmt").args = function()
            return { "-i", "4", "-ci", "-s", "-filename", "$FILENAME" }
        end

        local black = { "blackd", "black" }
        local prettier = { "prettierd", "prettier" }
        local shell = { "beautysh", "shellcheck", "shellharden", "shfmt" }

        require("conform").setup({
            formatters_by_ft = {
                bash = shell,
                c = { "clang-format" },
                cpp = { "clang-format" },
                css = { prettier },
                fish = { "fish_indent" },
                go = { "gofumpt", "goimports", "golines" },
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
                    args = require("conform.formatters.black").args,
                    stdin = true,
                },
                just = {
                    command = "just",
                    args = { "--fmt", "--unstable", "-f", "$FILENAME" },
                    stdin = false,
                },
            },
        })
    end,
    event = { "VeryLazy" },
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
