---@type LazySpec[]
return {
    {
        "lewis6991/gitsigns.nvim",
        event = ev.LazyFile,
        keys = {
            {
                -- From lewis6991
                -- Selects the current git conflict region using Neovim API, handling ancestor conflicts
                "<leader>gmc",
                function()
                    --- @param row integer
                    --- @return string
                    local function get_line(row)
                        return vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
                    end

                    --- @param row integer
                    --- @param end_row? integer
                    local function remove_line(row, end_row)
                        vim.api.nvim_buf_set_lines(0, row, (end_row or row) + 1, false, {})
                    end

                    local cursor = vim.api.nvim_win_get_cursor(0)
                    local cur_row = cursor[1] - 1

                    --- @type integer?, integer?, integer?, integer?
                    local start_row, ancestor_row, middle_row, end_row

                    -- Find start of conflict (<<<<<<<)
                    for i = cur_row, 0, -1 do
                        local line = get_line(i)

                        if line:match("^<<<<<<<") then
                            start_row = i
                            break
                        end
                    end

                    if not start_row then
                        vim.notify("No git start conflict region found", vim.log.levels.WARN)
                        return
                    end

                    -- Find ancestor (|||||||) and middle (=======) and end (>>>>>>>)
                    for i = start_row, vim.api.nvim_buf_line_count(0) - 1 do
                        local line = get_line(i)

                        if not ancestor_row and line:match("^|||||||") then
                            ancestor_row = i
                        elseif not middle_row and line:match("^=======") then
                            middle_row = i
                        elseif line:match("^>>>>>>>") then
                            end_row = i
                            break
                        end
                    end

                    if not middle_row then
                        vim.notify("No git conflict middle found", vim.log.levels.WARN)
                        return
                    end

                    if not end_row then
                        vim.notify("No git conflict end found", vim.log.levels.WARN)
                        return
                    end

                    if cur_row < (ancestor_row or middle_row) then
                        remove_line(ancestor_row or middle_row, end_row)
                        remove_line(start_row)
                    elseif ancestor_row and cur_row < middle_row then
                        remove_line(middle_row, end_row)
                        remove_line(start_row, ancestor_row)
                    else
                        remove_line(end_row)
                        remove_line(start_row, middle_row)
                    end
                end,
                "Select git conflict region",
            },
        },
        ---@module "gitsigns"
        ---@type Gitsigns.Config
        opts = {
            attach_to_untracked = true,
            diff_opts = {
                algorithm = "histogram",
                context_lines = 3,
                indent_heuristic = true,
                internal = true,
            },
            gh = true,
            --- @param buffer integer
            on_attach = function(buffer)
                local gs = package.loaded.gitsigns

                if gs == nil then
                    return
                end

                Snacks.toggle({
                    name = "Git Signs",
                    get = function()
                        return require("gitsigns.config").config.signcolumn
                    end,
                    set = function(state)
                        require("gitsigns").toggle_signs(state)
                    end,
                } --[[@as snacks.toggle.Opts]]):map("<space>tg")

                ---@param l string
                ---@param r function | string
                ---@param desc string
                ---@param mode string[]?
                local function bmap(l, r, desc, mode)
                    vim.keymap.set(mode or "n", l, r, { buffer = buffer, desc = desc })
                end

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

                -- stylua: ignore start
                bmap("]H", function() gs.nav_hunk("last") end, "Last Hunk")
                bmap("[H", function() gs.nav_hunk("first") end, "First Hunk")
                -- stylua: ignore end

                -- { 'n', ']g', function () actions.nav_hunk('next', { navigation_message = false }) end },
                -- { 'n', '[g', function () actions.nav_hunk('prev', { navigation_message = false }) end },

                bmap("<leader>gb", function()
                    gs.blame_line({ full = true, ignore_whitespace = true })
                end, "Git Blame")

                bmap("<leader>gc", function()
                    if vim.b.gitsigns_blame_line_dict then
                        gs.show_commit(vim.b.gitsigns_blame_line_dict.sha)
                    end
                end, "Git Commit")

                -- Git conflict mappings
                -- bmap("<leader>mc", "^[<>=]", "Merge Conflicts")
                -- bmap("<leader>gcu", "dd/|||<CR>0v/>>><CR>$x", "Git Conflict Choose Upstream")
                -- bmap("<leader>gcb", "0v/|||<CR>$x/====<CR>0v/>>><CR>$x", "Git Conflict Choose Base")
                -- bmap("<leader>gcs", "0v/====<CR>$x/>>><CR>dd", "Git Conflict Choose Stashed")

                bmap("<leader>gd", gs.diffthis, "Git Diff")

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
            _refresh_staged_on_update = true,
        },
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
