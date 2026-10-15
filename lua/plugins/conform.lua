---@type zpack.Spec
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
            format_after_save = nil,
            format_on_save = nil,
            formatters = {
                caddy = {
                    command = "caddy",
                    args = { "fmt", "-" },
                    stdin = true,
                },
                injected = {
                    options = {
                        ignore_errors = true,
                    },
                },
                jq = {
                    prepend_args = { "--sort-keys" },
                },
                xmlformatter = {
                    prepend_args = { "--blanks", "--indent", "4" },
                },
            },
            formatters_by_ft = {
                caddy = { "caddy" },
                go = { "gofumpt" },
                json = { "jq" },
                lua = { "stylua" },
                make = { "bake" },
                -- markdown = function(bufnr)
                --     return { require("lib.formatting").first(bufnr, "prettierd", "prettier"), "injected" }
                -- end,
                typescript = { "oxfmt" },
                pyproject = { "pyproject-fmt" },
                python = { "ruff_organize_imports", "ruff_format", "ruff_fix" },
                toml = function(bufnr)
                    return vim.fs.basename(nvim.file.filename(bufnr)) == "pyproject.toml" and { "pyproject-fmt" } or {}
                end,
                xml = { "xmlformatter" },
            },
        }
    end,
}
