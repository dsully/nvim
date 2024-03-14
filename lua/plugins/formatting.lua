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
        local formatters_by_ft = require("config.defaults").formatters

        for _, ft in ipairs({
            "css",
            "dockerfile",
            "html",
            "javascript",
            "javascriptreact",
            "jinja",
            "json",
            "jsonc",
            "lua",
            "markdown",
            "sql",
            "toml",
            "toml.pyproject",
            "typescript",
            "typescriptreact",
        }) do
            formatters_by_ft[ft] = { "dprint" }
        end

        return {
            format_on_save = function(bufnr)
                if vim.tbl_contains(require("config.defaults").ignored.file_types, vim.bo[bufnr].filetype) then
                    return
                end

                if vim.tbl_contains(require("config.defaults").ignored.buffer_types, vim.bo[bufnr].buftype) then
                    return
                end

                -- Disable autoformat for files in a certain path
                local bufname = vim.api.nvim_buf_get_name(bufnr)

                if bufname:match("/(node_modules|__pypackages__|site_packages|cargo/registry)/") then
                    return
                end

                return { async = true, timeout_ms = 99999, lsp_fallback = true }
            end,
            ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
            formatters = {
                caddy = {
                    command = "caddy",
                    args = { "fmt", "-" },
                    stdin = true,
                },
                dprint = {
                    args = { "fmt", "--stdin", "$FILENAME", "--config", vim.env.XDG_CONFIG_HOME .. "/dprint.jsonc" },
                },
                markdownlint = {
                    prepend_args = { string.format("--config=%s/markdownlint/config.yaml", vim.env.XDG_CONFIG_HOME) },
                },
                shfmt = {
                    prepend_args = { "-i", "2", "-ci", "-sr", "-s", "-bn" },
                },
            },
            formatters_by_ft = formatters_by_ft,
        }
    end,
}
