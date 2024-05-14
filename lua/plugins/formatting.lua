return {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    event = { "BufWritePre", "LspAttach" },
    keys = {
        {
            "<space>f",
            function()
                require("conform").format({ async = true, lsp_fallback = true, timeout_ms = 3000 })
            end,
            desc = "󰛗 Format Buffer",
        },
    },
    opts = function()
        local defaults = require("config.defaults")

        return {
            format_on_save = function(bufnr)
                --
                if not vim.tbl_contains(defaults.formatting.on_save, vim.bo[bufnr].filetype) then
                    return false
                end

                -- Disable autoformat for files in a certain path
                local bufname = vim.api.nvim_buf_get_name(bufnr)

                if bufname:match("/(node_modules|__pypackages__|site_packages|cargo/registry|product-spec.json)/") then
                    return false
                end

                return { timeout_ms = 500, lsp_fallback = true }
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
            formatters_by_ft = defaults.formatting.file_types,
        }
    end,
}
