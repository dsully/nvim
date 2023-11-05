return {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    config = function()
        require("conform").setup({
            formatters_by_ft = require("config.defaults").formatters,
            formatters = {
                caddy = {
                    command = "caddy",
                    args = { "fmt", "-" },
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
