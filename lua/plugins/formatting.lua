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
            if vim.tbl_contains(require("config.defaults").ignored.file_types, vim.bo[bufnr].filetype) then
                return
            end

            if vim.tbl_contains(require("config.defaults").ignored.buffer_types, vim.bo[bufnr].buftype) then
                return
            end

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
        formatters_by_ft = {
            just = { "just" },
        },
    },
}
