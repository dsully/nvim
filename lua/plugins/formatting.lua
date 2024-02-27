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
        format_on_save = function(bufnr)
            -- if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
            --     return
            -- end

            -- Disable with a global or buffer-local variable
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
            end

            -- Disable autoformat for files in a certain path
            local bufname = vim.api.nvim_buf_get_name(bufnr)

            if bufname:match("/node_modules/") or bufname:match("/cargo/registry/") or bufname:match("site-packages") then
                return
            end

            return { timeout_ms = 500, lsp_fallback = true }
        end,

        ---@type table<string, conform.FormatterUnit[]>
        formatters_by_ft = require("config.defaults").formatters,

        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
            caddy = {
                command = "caddy",
                args = { "fmt", "-" },
                stdin = true,
            },
            shfmt = {
                prepend_args = { "-i", "2", "-ci", "-sr", "-s", "-bn" },
            },
        },
    },
}
