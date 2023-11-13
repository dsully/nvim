return {
    "akinsho/bufferline.nvim",
    init = function()
        --
        for i = 1, 9 do
            vim.keymap.set("n", "<leader>" .. i, function()
                require("bufferline").go_to(i, true)
            end, { desc = "which_key_ignore" })

            -- Allow Option-N in Wezterm.
            vim.keymap.set("n", string.format("<M-%d>", i), function()
                require("bufferline").go_to(i, true)
            end, { desc = "which_key_ignore" })
        end

        -- Go to the last buffer.
        vim.keymap.set("n", "<leader>$", function()
            require("bufferline").go_to(-1, true)
        end, { desc = "which_key_ignore" })

        -- Always show tabs, but only load it if there is more than one.
        vim.api.nvim_create_autocmd({ "BufAdd", "TabEnter", "VimEnter", "WinEnter" }, {
            callback = function()
                if #vim.fn.getbufinfo({ buflisted = 1 }) >= 2 then
                    require("lazy").load({ plugins = { "bufferline.nvim" } })
                end
            end,
        })
    end,
    opts = {
        options = {
            always_show_bufferline = true,
            numbers = "ordinal",
            diagnostics = "nvim_lsp",
            show_buffer_close_icons = false,
            sort_by = "insert_at_end",
        },
    },
}
