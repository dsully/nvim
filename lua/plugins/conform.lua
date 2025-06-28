---@type LazySpec
return {
    ---@module "conform"
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    keys = {
        {
            "<space>f",
            function()
                require("conform").format({ async = true, lsp_format = "fallback", timeout_ms = 3000 } --[[@as conform.FormatOpts?]])
            end,
            desc = "Format Buffer",
        },
    },
    opts = function()
        ---@type conform.setupOpts
        return {
            format_on_save = {},
            formatters = {
                bake = {
                    command = "bake",
                    args = { "format", "$FILENAME" },
                    stdin = false,
                },
                caddy = {
                    command = "caddy",
                    args = { "fmt" },
                    stdin = true,
                },
                injected = {
                    options = {
                        ignore_errors = true,
                    },
                },
                shfmt = {
                    prepend_args = { "-i", "4", "-ci", "-sr", "-s", "-bn" },
                },
                xmlformatter = {
                    prepend_args = { "--blanks", "--indent", "4" },
                },
            },
            formatters_by_ft = defaults.formatting.file_types,
        }
    end,
}
