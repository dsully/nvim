---@type LazySpec[]
return {
    {
        "lewis6991/gitsigns.nvim",
        config = function(_, opts)
            vim.defer_fn(function()
                require("gitsigns").setup(opts)

                Snacks.toggle({
                    name = "Git Signs",
                    get = function()
                        return require("gitsigns.config").config.signcolumn
                    end,
                    set = function(state)
                        require("gitsigns").toggle_signs(state)
                    end,
                } --[[@as snacks.toggle.Opts]]):map("<space>tg")
            end, 500)
        end,
        event = ev.LazyFile,
        ---@module "gitsigns"
        ---@type Gitsigns.Config
        opts = {
            attach_to_untracked = true,
            --- @param buffer integer
            on_attach = function(buffer)
                local gs = package.loaded.gitsigns

                ---@param mode string[]?
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
                end, "Stage Lines(s)", { "n", "v" })

                bmap("<leader>gr", function()
                    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Reset Stage Lines(s)", { "n", "v" })
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
                    toplevel = vim.fs.abspath("~"),
                    gitdir = nvim.file.xdg_config("/repos/dotfiles"),
                },
            },
        },
        _new_sign_calc = true,
    },
    {
        "juansalvatore/git-dashboard-nvim",
        opts = {
            basepoints = { "master", "main" },
            branch = { "master", "main" },
            centered = false,
            colors = {
                branch_highlight = colors.yellow.base,
                dashboard_title = colors.cyan.bright,
                days_and_months_labels = colors.cyan.bright,
                empty_square_highlight = colors.cyan.bright,
                filled_square_highlights = { "#002c39", "#094d5b", "#387180", "#6098a7", colors.cyan.bright, "#c0faff" },
            },
            day_label_gap = "  ",
            hide_cursor = true,
            show_current_branch = true,
            use_git_username_as_author = true,
        },
    },
}
