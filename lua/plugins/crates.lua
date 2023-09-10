return {
    "Saecki/crates.nvim",
    config = function()
        require("crates").setup({
            popup = {
                autofocus = true,
                border = vim.g.border,
            },
        })

        vim.keymap.set("n", "<leader>cu", require("crates").upgrade_crate, { desc = "Upgrade crate." })
        vim.keymap.set("n", "<leader>cU", require("crates").upgrade_all_crates, { desc = "Upgrade all crates." })

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
