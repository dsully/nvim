return {
    "goolord/alpha-nvim",
    opts = function()
        local dashboard = require("alpha.themes.dashboard")

        dashboard.section.header.val = {
            [[                                                                       ]],
            [[                                                                     ]],
            [[       ████ ██████           █████      ██                     ]],
            [[      ███████████             █████                             ]],
            [[      █████████ ███████████████████ ███   ███████████   ]],
            [[     █████████  ███    █████████████ █████ ██████████████   ]],
            [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
            [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
            [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
            [[                                                                       ]],
        }

        dashboard.section.header.opts.hl = "AlphaHeader"
        dashboard.section.footer.opts.hl = "AlphaFooter"

        dashboard.section.buttons.opts.spacing = 0
        dashboard.section.buttons.val = {
            dashboard.button("l", "󰁯  Load Session        ", "<cmd> lua require('persisted').load()<CR>"),
            dashboard.button("n", "  New File            ", "<cmd> ene <BAR> startinsert<CR>"),
            dashboard.button("r", "󰈢  Recently Opened     ", "<cmd> Telescope oldfiles<CR>"),
            dashboard.button("f", "󰈞  Find Files          ", "<cmd> Telescope find_files hidden=true path_display=smart<CR>"),
            dashboard.button("g", "  Find Text           ", "<cmd> Telescope live_grep <CR>"),
            dashboard.button("p", "󰓅  Profile Plugins     ", "<cmd> Lazy profile<CR>"),
            dashboard.button("u", "  Update Plugins      ", "<cmd> Lazy sync<CR>"),
            dashboard.button("q", "󰗼  Quit Neovim         ", "<cmd> qa!<CR>"),
        }

        dashboard.config.layout = {
            { type = "padding", val = vim.fn.max({ 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) }) },
            dashboard.section.header,
            { type = "padding", val = 2 },
            {
                type = "text",
                -- stylua: ignore
                val = {
                    "┌────────────   Today is " .. os.date("%a %d %b") .. " ────────────┐",
                    "│                                                │",
                    "└───══───══───══───  " .. os.date(" %H:%M") .. "  ───══───══───══────┘",
                },
                opts = { position = "center" },
            },
            { type = "padding", val = 2 },
            dashboard.section.buttons,
            { type = "padding", val = 1 },
            dashboard.section.footer,
        }

        return dashboard
    end,
    config = function(_, dashboard)
        -- Close Lazy and re-open when the dashboard is ready
        if vim.o.filetype == "lazy" then
            vim.cmd.close()
            vim.api.nvim_create_autocmd("User", {
                callback = require("lazy").show,
                desc = "Close Lazy UI on dashboard load.",
                pattern = "AlphaReady",
            })
        end

        vim.api.nvim_create_autocmd("FileType", {
            desc = "Hide tab line and status lines on startup screen.",
            callback = function()
                vim.opt_local.buflisted = true
                vim.opt_local.colorcolumn = ""
                vim.opt_local.laststatus = 0
                vim.opt_local.ruler = false
                vim.opt_local.showtabline = 0
            end,
            once = true,
            pattern = "alpha",
        })

        require("alpha").setup(dashboard.opts)

        vim.api.nvim_create_autocmd("User", {
            callback = function()
                local stats = require("lazy").stats()
                local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

                local version = vim.version()
                local v = ""

                if version ~= nil then
                    v = string.format("v%s.%s.%s ", version.major, version.minor, version.patch)
                end

                dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"

                vim.cmd.AlphaRedraw()
            end,
            desc = "Dashboard Footer Update",
            pattern = "LazyVimStarted",
        })
    end,
    cond = function()
        return vim.fn.argc() == 0
    end,
    event = "VimEnter",
    priority = 5, -- Load after persistence.nvim
}
