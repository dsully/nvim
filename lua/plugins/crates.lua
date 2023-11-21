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

                vim.keymap.set("n", "<leader>cu", crates.upgrade_crate, { buffer = bufnr, desc = "Upgrade crate." })
                vim.keymap.set("n", "<leader>cU", crates.upgrade_all_crates, { buffer = bufnr, desc = "Upgrade all crates." })
            end,
            popup = {
                autofocus = true,
                border = vim.g.border,
            },
            src = {
                cmp = {
                    enabled = true,
                },
            },
        })

        local defaults = require("config.defaults")

        -- Add the nvim-cmp source if we're editing Cargo.toml
        table.insert(defaults.cmp.symbols, { async_path = " [Path]" })
        table.insert(defaults.cmp.symbols, { crates = " [󱘗 Crates]" })

        if defaults.cmp.backend == "nvim-cmp" then
            require("crates.src.cmp").setup()

            require("cmp").setup.buffer({
                sources = {
                    {
                        { name = "crates" },
                        { name = "async_path" },
                    },
                    {
                        { name = "buffer", keyword_length = 5 },
                    },
                },
            })
        end
    end,
    event = { "BufRead Cargo.toml" },
}
