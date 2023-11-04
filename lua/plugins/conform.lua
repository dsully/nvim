return {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    config = function()
        local root_file = require("conform.util").root_file

        require("conform").setup({
            formatters_by_ft = require("config.defaults").formatters,
            formatters = {
                caddy = {
                    command = "caddy",
                    args = { "fmt", "-" },
                    cwd = root_file({ "Caddyfile" }),
                    stdin = true,
                },
                markdownlint = {
                    prepend_args = { string.format("--config=%s/markdownlint/config.yaml", vim.env.XDG_CONFIG_HOME) },
                },
                ruff_format = {
                    command = "ruff",
                    args = function()
                        -- This needs to be dynamic and not just at Neovim startup time.
                        return vim.tbl_flatten({
                            { "format", "--stdin-filename", "$FILENAME", "-" },
                            require("plugins.lsp.python").ruff_format_args(),
                        })
                    end,
                    cwd = root_file({ "setup.cfg", "pyproject.toml", "ruff.toml" }),
                    inherit = false,
                    stdin = true,
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
