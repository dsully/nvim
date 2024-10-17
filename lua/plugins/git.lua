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
            { "<leader>go", function() vim.cmd.GitLink({ bang = true }) end, desc = "Open Git URL", mode = { "n", "x" } },
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
        -- For Github PR view
        "chrisgrieser/nvim-tinygit",
        opts = {
            commitMsg = {
                conventionalCommits = {
                    enforce = true,
                },
            },
        },
    },
    {
        "SuperBo/fugit2.nvim",
        build = "rockspec",
        cmd = { "Fugit2", "Fugit2Blame", "Fugit2Graph" },
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
                width = 0.8,
                height = 0.8,
                libgit2_path = vim.env.HOMEBREW_PREFIX .. lib,
            }
        end,
    },
    {
        "aaronhallaert/advanced-git-search.nvim",
        cmd = "AdvancedGitSearch",
        config = function()
            require("advanced_git_search.fzf").setup({
                diff_plugin = "diffview",
                keymaps = {
                    -- following keymaps can be overridden
                    toggle_date_author = "<C-w>",
                    open_commit_in_browser = "<C-o>",
                    copy_commit_hash = "<C-y>",
                    show_entire_commit = "<C-e>",
                },
                show_builtin_git_pickers = true,
            })
        end,
        keys = { { "<leader>gS", vim.cmd.AdvancedGitSearch, desc = "Search" } },
    },
}
