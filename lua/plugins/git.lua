return {
    {
        "lewis6991/gitsigns.nvim",
        event = "LazyFile",
        keys = {
            { "<leader>g/", [[/^\(|||||||\|=======\|>>>>>>>\|<<<<<<<\)<CR>]], desc = "Search for conflict markers" },
        },
        opts = {
            attach_to_untracked = true,
            keymaps = nil,
            preview_config = {
                border = vim.g.border,
            },
            --- @param buffer integer
            on_attach = function(buffer)
                local gs = package.loaded.gitsigns

                local function bmap(l, r, desc, mode)
                    vim.keymap.set(mode or "n", l, r, { buffer = buffer, desc = desc })
                end

                bmap("]c", gs.next_hunk, "Next Git Hunk")
                bmap("[c", gs.prev_hunk, "Previous Git Hunk")

                bmap("<leader>gb", function()
                    gs.blame_line({ full = true, ignore_whitespace = true })
                end, "Git Blame")

                bmap("<leader>gR", gs.reset_buffer, "Reset Git Buffer")
                bmap("<leader>gp", gs.preview_hunk, "Preview Git Hunk")
                bmap("<leader>gU", gs.undo_stage_hunk, "Undo Git Stage Hunk")

                bmap("<leader>gD", gs.toggle_deleted, "Git Deleted Toggle")
                bmap("<leader>gB", gs.toggle_current_line_blame, "Git Blame Toggle")

                bmap("<leader>gs", function()
                    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Stage Lines(s)", { "n", "x" })

                bmap("<leader>gr", function()
                    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Reset Stage Lines(s)", { "n", "x" })
            end,
            sign_priority = 100,
            signs_staged_enable = false,
            trouble = true,
            worktrees = {
                {
                    toplevel = vim.g.home,
                    gitdir = string.format("%s/repos/dotfiles", vim.env.XDG_CONFIG_HOME),
                },
            },
        },
    },
    {
        "linrongbin16/gitlinker.nvim",
        cmd = "GitLink",
        -- stylua: ignore
        keys = {
            { "<leader>gC", vim.cmd.GitLink, desc = "Copy Git URL", mode = { "n", "x" } },
            { "<leader>go", function() vim.cmd.GitLink({ bang = true }) end, desc = "Open Git URL", mode = { "x", "x" } },
        },
        opts = {
            message = false,
        },
    },
    {
        "topaxi/gh-actions.nvim",
        build = "make",
        cmd = "GHActions",
        dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
        keys = {
            { "<leader>gha", vim.cmd.GhActions, desc = "Open Github Actions" },
        },
        opts = true,
    },
    -- {
    --     "aspeddro/gitui.nvim",
    --     -- stylua: ignore
    --     keys = { { "<space>g", function() require("gitui").open() end, desc = " Git UI" } },
    --     opts = {
    --         command = {
    --             enable = false,
    --         },
    --         window = {
    --             options = {
    --                 border = vim.g.border,
    --             },
    --         },
    --     },
    -- },
    {
        "dlvhdr/gh-addressed.nvim",
        cmd = "GHReviewComments",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "folke/trouble.nvim",
        },
        keys = {
            { "<leader>ghc", vim.cmd.GHReviewComments, desc = "GitHub Review Comments" },
        },
    },
    {
        "SuperBo/fugit2.nvim",
        build = "rockspec",
        cmd = { "Fugit2", "Fugit2Graph" },
        dependencies = {
            "MunifTanjim/nui.nvim",
            "chrisgrieser/nvim-tinygit", -- optional: for Github PR view
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            -- stylua: ignore
            { "<space>g", function() require("fugit2").git_status() end, desc = "Git UI" },
        },
        opts = function()
            local lib = "/lib/libgit2.dylib"

            if vim.g.os == "Linux" then
                lib = "/lib/libgit2.so"
            end

            return {
                libgit2_path = vim.env.HOMEBREW_PREFIX .. lib,
            }
        end,
    },
}
