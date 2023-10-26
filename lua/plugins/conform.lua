return {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    config = function()
        local root_file = require("conform.util").root_file

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

        require("conform").setup({
            formatters_by_ft = vim.g.defaults.formatters,
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
                markdownlint = {
                    prepend_args = { string.format("--config=%s/markdownlint/config.yaml", vim.env.XDG_CONFIG_HOME) },
                },
                shfmt = {
                    prepend_args = { "-i", "2", "-ci", "-sr", "-s", "-bn" },
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
