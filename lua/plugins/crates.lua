return {
    "Saecki/crates.nvim",
    config = function()
        local crates = require("crates")

        crates.setup({
            on_attach = function(bufnr)
                vim.keymap.set("n", "K", function()
                    if crates.popup_available() then
                        crates.show_popup()
                    else
                        vim.lsp.buf.hover()
                    end
                end, {

                    buffer = bufnr,
                    desc = "Show Crate Documentation",
                })

                vim.keymap.set("n", "<leader>cu", require("crates").upgrade_crate, { buffer = bufnr, desc = "Upgrade crate." })
                vim.keymap.set("n", "<leader>cU", require("crates").upgrade_all_crates, { buffer = bufnr, desc = "Upgrade all crates." })
            end,
            popup = {
                autofocus = true,
                border = vim.g.border,
            },
        })

        vim.keymap.set("n", "<leader>cu", crates.upgrade_crate, { desc = "Upgrade crate." })
        vim.keymap.set("n", "<leader>cU", crates.upgrade_all_crates, { desc = "Upgrade all crates." })

        -- Add the nvim-cmp source if we're editing Cargo.toml
        require("cmp").setup.buffer({
            sources = {
                { name = "crates" },
                { name = "async_path" },
                { name = "buffer" },
            },
        })
    end,
    event = { "BufRead Cargo.toml" },
}
