return {
    "lewis6991/gitsigns.nvim",
    config = function()
        require("gitsigns").setup({
            keymaps = nil,
            -- Boost efficiency for the internal sign related operations
            -- Ref: https://github.com/lewis6991/gitsigns.nvim/pull/438
            _extmark_signs = true,
            _inline2 = true,
            preview_config = {
                border = vim.g.border,
            },
            on_attach = function()
                local gs = package.loaded.gitsigns

                vim.keymap.set("n", "]c", gs.next_hunk, { desc = "Next Git Hunk" })
                vim.keymap.set("n", "[c", gs.prev_hunk, { desc = "Previous Git Hunk" })

                vim.keymap.set("n", "<leader>gb", gs.blame_line, { desc = "Git Blame" })
                vim.keymap.set("n", "<leader>gR", gs.reset_buffer, { desc = "Reset Git Buffer" })
                vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "Preview Git Hunk" })
                vim.keymap.set("n", "<leader>gU", gs.undo_stage_hunk, { desc = "Undo Git Stage Hunk" })

                vim.keymap.set("n", "<leader>gd", gs.toggle_deleted, { desc = "Git Deleted Toggle" })
                vim.keymap.set("n", "<leader>gB", gs.toggle_current_line_blame, { desc = "Git Blame Toggle" })

                vim.keymap.set({ "n", "x" }, "<leader>gs", function()
                    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, { desc = "Stage Lines(s)" })

                vim.keymap.set({ "n", "x" }, "<leader>gr", function()
                    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, { desc = "Reset Stage Lines(s)" })
            end,
            trouble = true,
            worktrees = {
                {
                    toplevel = vim.g.home,
                    gitdir = string.format("%s/.config/repos/dotfiles", vim.g.home),
                },
            },
        })
    end,
    event = "VeryLazy",
}
