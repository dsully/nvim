return {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    event = { "BufWritePre", "LspAttach" },
    keys = {
        {
            "<space>f",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            desc = "󰛗 Format Buffer",
        },
    },
    opts = function()
        return {
            format = function()
                return { async = true, timeout_ms = 3000, lsp_fallback = true }
            end,
            format_on_save = function(bufnr)
                -- Don't format-on-save for Rust, as rust-analyzer is busy checking.
                if vim.bo[bufnr].filetype == "rust" then
                    return
                end

                if vim.tbl_contains(require("config.defaults").ignored.file_types, vim.bo[bufnr].filetype) then
                    return false
                end

                if vim.tbl_contains(require("config.defaults").ignored.buffer_types, vim.bo[bufnr].buftype) then
                    return false
                end

                -- Disable autoformat for files in a certain path
                local bufname = vim.api.nvim_buf_get_name(bufnr)

                if bufname:match("/(node_modules|__pypackages__|site_packages|cargo/registry|product-spec.json)/") then
                    return false
                end

                return { async = true, timeout_ms = 3000, lsp_fallback = true }
            end,
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
                shfmt = {
                    prepend_args = { "-i", "2", "-ci", "-sr", "-s", "-bn" },
                },
                -- Remove when https://github.com/tamasfe/taplo/issues/560 is addressed.
                taplo = {
                    args = { "format", "--config=" .. vim.env.XDG_CONFIG_HOME .. "/taplo.toml", "-" },
                },
            },
            formatters_by_ft = require("config.defaults").formatters,
        }
    end,
}
