return {
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                keymaps = nil,
                _inline2 = true,
                preview_config = {
                    border = vim.g.border,
                },
                on_attach = function(buffer)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, desc)
                        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
                    end

                    map("n", "]c", gs.next_hunk, "Next Git Hunk")
                    map("n", "[c", gs.prev_hunk, "Previous Git Hunk")

                    map("n", "<leader>gb", function()
                        gs.blame_line({ full = true, ignore_whitespace = true })
                    end, "Git Blame")

                    map("n", "<leader>gR", gs.reset_buffer, "Reset Git Buffer")
                    map("n", "<leader>gp", gs.preview_hunk, "Preview Git Hunk")
                    map("n", "<leader>gU", gs.undo_stage_hunk, "Undo Git Stage Hunk")

                    map("n", "<leader>gd", gs.toggle_deleted, "Git Deleted Toggle")
                    map("n", "<leader>gB", gs.toggle_current_line_blame, "Git Blame Toggle")

                    map({ "n", "x" }, "<leader>gs", function()
                        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                    end, "Stage Lines(s)")

                    map({ "n", "x" }, "<leader>gr", function()
                        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                    end, "Reset Stage Lines(s)")
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
        event = vim.g.defaults.lazyfile,
    },
    {
        "linrongbin16/gitlinker.nvim",
        keys = {
            {
                "<leader>gc",
                function()
                    return require("gitlinker").get_buf_range_url("n")
                end,
                desc = "Copy Git URL",
            },
            {
                "<leader>go",
                function()
                    return require("gitlinker").get_buf_range_url("n", {
                        action_callback = function(url)
                            vim.system({ vim.g.opener, "--background", url })
                        end,
                    })
                end,
                desc = "Open Git URL",
            },
        },
        opts = {
            opts = {
                print_url = false,
            },
        },
    },
    {
        "topaxi/gh-actions.nvim",
        build = "make",
        cmd = "GhActions",
        dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
        keys = {
            { "<leader>gh", vim.cmd.GhActions, desc = "Open Github Actions" },
        },
        opts = true,
    },
}
