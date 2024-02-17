return {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    keys = {
        {
            "<space>f",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            desc = "󰛗 Format Buffer",
        },
    },
    opts = {
        ---@type table<string, conform.FormatterUnit[]>
        formatters_by_ft = require("config.defaults").formatters,

        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
            caddy = {
                command = "caddy",
                args = { "fmt", "-" },
                stdin = true,
            },
            markdownlint = {
                prepend_args = { string.format("--config=%s/markdownlint/config.yaml", vim.env.XDG_CONFIG_HOME) },
            },
            -- Remove when https://github.com/tamasfe/taplo/issues/560 is addressed.
            taplo = {
                args = { "format", "--config=" .. vim.env.XDG_CONFIG_HOME .. "/taplo.toml", "-" },
            },
            shfmt = {
                prepend_args = { "-i", "2", "-ci", "-sr", "-s", "-bn" },
            },
        },
    },
}
