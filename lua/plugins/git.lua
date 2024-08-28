return {
    {
        "lewis6991/gitsigns.nvim",
        event = ev.LazyFile,
        opts = {
            attach_to_untracked = true,
            --- @param buffer integer
            on_attach = function(buffer)
                local gs = package.loaded.gitsigns

                local function bmap(l, r, desc, mode)
                    vim.keymap.set(mode or "n", l, r, { buffer = buffer, desc = desc })
                end

                -- stylua: ignore start
                bmap("]h", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "]c", bang = true })
                    else
                        gs.nav_hunk("next")
                    end
                end, "Next Hunk")

                bmap("[h", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "[c", bang = true })
                    else
                        gs.nav_hunk("prev")
                    end
                end, "Prev Hunk")

                bmap("]H", function() gs.nav_hunk("last") end, "Last Hunk")
                bmap("[H", function() gs.nav_hunk("first") end, "First Hunk")

                -- { 'n', ']g', function () actions.nav_hunk('next', { navigation_message = false }) end },
                -- { 'n', '[g', function () actions.nav_hunk('prev', { navigation_message = false }) end },

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
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
            signs_staged = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
            },
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
        "aspeddro/gitui.nvim",
        -- stylua: ignore
        keys = { { "<space>G", function() require("gitui").open() end, desc = "Git UI" } },
        opts = {
            command = {
                enable = false,
            },
            window = {
                options = {
                    border = defaults.ui.border.name,
                },
            },
        },
    },
    {
        "SuperBo/fugit2.nvim",
        build = "rockspec",
        cmd = { "Fugit2", "Fugit2Graph" },
        dependencies = {
            "MunifTanjim/nui.nvim",
            "chrisgrieser/nvim-tinygit", -- For Github PR view
            "nvim-lua/plenary.nvim",
        },
        keys = {
            -- stylua: ignore
            { "<space>g", function() require("fugit2").git_status() end, desc = "Git UI (FuGit)" },
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
