return {
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
            day_label_gap = "\t",
            hide_cursor = false,
            show_current_branch = true,
            use_git_username_as_author = true,
        },
    },
    {
        "goolord/alpha-nvim",
        config = function(_, dashboard)
            -- Close Lazy and re-open when the dashboard is ready
            if vim.o.filetype == "lazy" then
                vim.cmd.close()

                ev.on(ev.User, require("lazy").show, {
                    desc = "Close Lazy UI on dashboard load.",
                    pattern = "AlphaReady",
                    once = true,
                })
            end

            ev.on(ev.FileType, function()
                vim.opt_local.laststatus = 0
            end, {
                desc = "Hide tab line and status lines on startup screen.",
                once = true,
                pattern = "alpha",
            })

            ev.on(ev.BufUnload, function()
                vim.opt_local.laststatus = 3
            end, {
                buffer = 0,
                desc = "Re-enable status line.",
                once = true,
            })

            require("alpha").setup(dashboard.opts)

            ev.on(ev.User, function()
                local stats = require("lazy").stats()
                local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

                dashboard.section.footer.val = "⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"

                vim.cmd.AlphaRedraw()
            end, {
                desc = "Dashboard Footer Update",
                pattern = "LazyVimStarted",
            })
        end,
        cond = function()
            return vim.fn.argc() == 0
        end,
        event = ev.VimEnter,
        init = function()
            hl.apply({
                { AlphaHeader = { fg = colors.blue.bright } },
                { AlphaFooter = { fg = colors.blue.base } },
            })
        end,
        opts = function()
            ---@param c string
            local cmd = function(c)
                return string.format("<cmd>%s<cr>", c)
            end

            local startify = require("alpha.themes.theta")
            local dashboard = require("alpha.themes.dashboard")

            local heatmap = {
                type = "text",
                val = require("git-dashboard-nvim").heatmap(),
                opts = {
                    position = "center",
                },
            }

            local function button(lhs, txt, rhs, opts)
                lhs = lhs:gsub("%s", ""):gsub("SPC", "<leader>")

                local default_opts = {
                    position = "center",
                    shortcut = "[" .. lhs .. "] ",
                    cursor = 1,
                    width = 52,
                    align_shortcut = "right",
                    hl_shortcut = { { "Keyword", 0, 1 }, { "Function", 1, #lhs + 1 }, { "Keyword", #lhs + 1, #lhs + 2 } },
                    shrink_margin = false,
                    keymap = { "n", lhs, rhs, { noremap = true, silent = true, nowait = true } },
                }

                opts = vim.tbl_deep_extend("force", default_opts, opts or {})

                return {
                    type = "button",
                    val = string.format(" %-1s  %s", opts.icon or "", txt),
                    on_press = function()
                        keys.feed(rhs .. "<Ignore>", "t")
                    end,
                    opts = opts,
                }
            end

            local buttons = {
                type = "group",
                val = {
                    {
                        type = "text",
                        val = string.rep("─", 50),
                        opts = {
                            hl = "FloatBorder",
                            position = "center",
                        },
                    },
                    { type = "padding", val = 1 },
                    button("l", "Load Session        ", cmd("SessionLoad"), { icon = "󰁯 ", hl = { { "String", 1, 2 }, { "Normal", 3, 52 } } }),
                    button("n", "New File            ", cmd("ene <BAR> startinsert"), { icon = " ", hl = { { "Normal", 1, 2 }, { "Normal", 3, 52 } } }),
                    button("f", "Find File           ", cmd("FzfLua files"), { icon = "󰱼 ", hl = { { "Normal", 1, 2 }, { "Normal", 3, 52 } } }),
                    button("g", "Find Text           ", cmd("FzfLua live_grep"), { icon = " ", hl = { { "Normal", 1, 2 }, { "Normal", 3, 52 } } }),
                    button("p", "Profile Plugins     ", cmd("Lazy profile"), { icon = "󰁯 ", hl = { { "@comment.todo", 1, 2 }, { "Normal", 3, 52 } } }),
                    button("u", "Update Plugins      ", cmd("Lazy sync"), { icon = " ", hl = { { "Keyword", 1, 2 }, { "Normal", 3, 52 } } }),
                    button("q", "Quit Neovim         ", cmd("qa!"), { icon = " ", hl = { { "@text.strong", 1, 2 }, { "Normal", 3, 52 } } }),
                    {
                        type = "text",
                        val = string.rep("─", 50),
                        opts = {
                            hl = "FloatBorder",
                            position = "center",
                        },
                    },
                },
            }

            local mru = {
                type = "group",
                val = {
                    {
                        type = "text",
                        val = "[ Recent files ]",
                        opts = {
                            hl = "Function",
                            position = "center",
                        },
                    },
                    { type = "padding", val = 1 },
                    {
                        type = "group",
                        val = function()
                            return { startify.mru(1, vim.uv.cwd(), 7) }
                        end,
                    },
                    { type = "padding", val = 1 },
                },
            }

            dashboard.config.layout = {
                -- { type = "padding", val = vim.fn.max({ 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) }) },
                { type = "padding", val = 2 },
                heatmap,
                mru,
                buttons,
                { type = "padding", val = 1 },
                dashboard.section.footer,
            }

            return dashboard
        end,
        priority = 5, -- Load after session manager.
    },
}
