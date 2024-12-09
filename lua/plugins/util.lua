return {
    { "nvim-lua/plenary.nvim" },
    { "MunifTanjim/nui.nvim" },
    { "echasnovski/mini.nvim", lazy = false },
    {
        "stevearc/resession.nvim",
        init = function()
            local function session_name()
                local cwd = tostring(vim.uv.cwd())
                local obj = vim.system({ "git", "branch", "--show-current" }, { text = true }):wait()

                return obj.code == 0 and string.format("%s-%s", cwd, vim.trim(obj.stdout)) or cwd
            end

            vim.api.nvim_create_user_command("SessionLoad", function()
                -- Work around nougat and mini.icons not being loaded.
                require("mini.icons")
                require("resession").load(session_name(), { silence_errors = false })
            end, { desc = "Session Load" })

            ev.on(ev.VimLeavePre, function()
                require("resession").save(session_name(), { notify = false })
            end, {
                desc = "Save session on exit.",
            })
        end,
        opts = {
            buf_filter = function(bufnr)
                local buftype = vim.bo[bufnr].buftype
                local ignored = defaults.ignored

                if buftype ~= "" and buftype ~= "acwrite" then
                    return false
                end

                if vim.tbl_contains(ignored.buffer_types, buftype) or vim.tbl_contains(ignored.file_types, vim.bo[bufnr].filetype) then
                    return false
                end

                --- Escape special pattern matching characters in a string
                ---@param input string
                ---@return string
                local function escape_pattern(input)
                    local magic_chars = { "%", "(", ")", ".", "+", "-", "*", "?", "[", "^", "$" }

                    for _, char in ipairs(magic_chars) do
                        input = input:gsub("%" .. char, "%%" .. char)
                    end

                    return input
                end

                local cwd = tostring(vim.uv.cwd())

                for _, pattern in ipairs(ignored.paths) do
                    if cwd:find(escape_pattern(tostring(vim.fn.expand(pattern)))) then
                        return false
                    end
                end

                return vim.bo[bufnr].buflisted
            end,
        },
        priority = 100, -- Load before alpha.nvim
    },
    {
        "vhyrro/toml-edit.lua",
        build = "rockspec",
        priority = 1000,
    },
    -- Pretty screen shots.
    {
        "mistricky/codesnap.nvim",
        build = "make build_generator",
        cmd = {
            "CodeSnap",
            "CodeSnapSave",
        },
        keys = {
            { "<leader>cS", "", desc = "󰹑 Screen Shots", mode = { "x" } },
            { "<leader>cSs", "<cmd>CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
            { "<leader>cSS", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "Save selected code snapshot in ~/Pictures" },
        },
        opts = {
            bg_theme = "dusk",
            has_breadcrumbs = true,
            save_path = vim.env.XDG_PICTURES_DIR,
            watermark = "",
        },
    },
    {
        "xvzc/chezmoi.nvim",
        cmd = {
            "ChezmoiEdit",
            "ChezmoiList",
        },
        init = function()
            -- Watch chezmoi files for changes in the source-path, and apply them.
            ev.on(ev.BufWritePost, function(args)
                if args.file and args.file:match(".tmpl") then
                    return
                end

                vim.schedule(require("chezmoi.commands.__edit").watch)
            end, {
                pattern = { vim.env.XDG_DATA_HOME .. "/chezmoi/home/*" },
            })

            -- Watch chezmoi files for changes in the target-path, and add them.
            ev.on(ev.BufReadPost, function()
                vim.defer_fn(function()
                    local ok, targets = pcall(require("chezmoi.commands").list, { args = { "--include", "files", "--path-style", "absolute" } })

                    if ok then
                        ev.on(ev.BufWritePost, function(args)
                            notify.info("chezmoi: Adding changes to: " .. args.file)

                            vim.system({ "chezmoi", "add", args.file }, { text = true }):wait()
                        end, {
                            desc = "Apply chezmoi changes via 'chezmoi edit'",
                            pattern = targets,
                        })
                    end
                end, 500)
            end, {
                once = true,
            })

            vim.api.nvim_create_user_command("ChezmoiFzf", function()
                require("fzf-lua").fzf_exec(require("chezmoi.commands").list({}), {
                    actions = {
                        ["default"] = function(selected, _opts)
                            require("chezmoi.commands").edit({
                                targets = { vim.env.HOME .. selected[1] },
                                args = { "--watch" },
                            })
                        end,
                    },
                })
            end, { desc = "Chezmoi Fzf" })
        end,
        opts = {},
    },
    {
        "folke/snacks.nvim",
        config = function(_, opts)
            local notify = vim.notify
            require("snacks").setup(opts)
            -- Restore vim.notify after snacks setup and let noice.nvim take over
            -- this is needed to have early notifications show up in noice history
            vim.notify = notify
        end,
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            bigfile = { enabled = true },
            gitbrowse = {
                notify = false,
            },
            notifier = {
                enabled = true,
                timeout = 3000,
                width = { min = 40, max = 0.4 },
                height = { min = 1, max = 0.6 },
                --
                -- Editor margin to keep free. tabline and statusline are taken into account automatically
                margin = { top = 0, right = 1, bottom = 0 },
                padding = true, -- add 1 cell of left/right padding to the notification window
                sort = { "added" }, -- sort by level and time
                icons = {
                    error = defaults.icons.diagnostics.error,
                    warn = defaults.icons.diagnostics.warn,
                    info = defaults.icons.diagnostics.info,
                    debug = defaults.icons.diagnostics.debug,
                    trace = defaults.icons.diagnostics.trace,
                },
                ---@type snacks.notifier.style
                style = "compact",
                top_down = true, -- place notifications from top to bottom
                date_format = "%R", -- time format for notifications
                refresh = 50, -- refresh at most every 50ms
            },
            statuscolumn = {
                enabled = true,
                left = { "git" },
                right = { "sign" },
                git = { patterns = { "GitSign" } },
            },
            styles = {
                notification = {
                    border = defaults.ui.border.name,
                    wo = { wrap = true },
                },
                scratch = {
                    border = defaults.ui.border.name,
                    height = 0.8,
                    width = 0.8,
                },
                terminal = defaults.ui.float,
                win = defaults.ui.float,
            },
            words = { enabled = true },
        },
        -- stylua: ignore
        keys = {
            ---@diagnostic disable-next-line: param-type-mismatch
            { "<leader>nd", function() Snacks.notifier:hide() end, desc = "Notification: Dismiss" },
            { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "snacks: goto next reference" },
            { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "snacks: goto prev reference" },

            { [[<C-\>]], function() Snacks.terminal.toggle(vim.env.SHELL) end, mode = { "n", "t" }, desc = "Terminal" },

            -- Git helpers.
            { "<leader>go", function() Snacks.gitbrowse.open() end, desc = "Open Git URL" },
            { "<leader>gC", function()
                Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
            end, desc = "Copy Git URL" },

            -- Profiler
            { "<leader>pS", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },

            -- Scratch
            { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
        },
        init = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = ev.VeryLazy,
                callback = function()
                    local snacks = require("snacks")

                    -- Setup some globals for debugging (lazy-loaded)
                    _G.dbg = function(...)
                        snacks.debug.inspect(...)
                    end

                    _G.bt = snacks.debug.backtrace
                    _G.notify = snacks.notify

                    vim.print = _G.dbg -- Override print to use snacks for `:=` command

                    -- Toggle mappings
                    snacks.toggle.diagnostics():map("<space>td")
                    snacks.toggle.inlay_hints():map("<space>ti")
                    snacks.toggle.line_number():map("<space>tn")
                    snacks.toggle.treesitter():map("<space>tt")
                    snacks.toggle.option("spell", { name = "Spelling" }):map("<space>ts")
                    snacks.toggle.option("wrap", { name = "Wrap" }):map("<space>tw")

                    snacks.toggle.profiler():map("<leader>pP")
                    snacks.toggle.profiler_highlights():map("<leader>pH")
                end,
            })

            hl.apply({
                { SnacksNormal = { link = "Normal" } },
                { SnacksBackdrop = { link = "Normal" } },

                { SnacksNotifierIconTrace = { fg = colors.gray.base } },
                { SnacksNotifierBorderTrace = { fg = colors.white.bright } },

                { SnacksNotifierIconDebug = { fg = colors.white.base } },
                { SnacksNotifierBorderDebug = { fg = colors.white.bright } },

                { SnacksNotifierIconInfo = { fg = colors.cyan.base } },
                { SnacksNotifierBorderInfo = { fg = colors.white.bright } },

                { SnacksNotifierIconWarn = { fg = colors.yellow.base } },
                { SnacksNotifierBorderWarn = { fg = colors.white.bright } },

                { SnacksNotifierIconError = { fg = colors.red.base } },
                { SnacksNotifierBorderError = { fg = colors.white.bright } },
            })
        end,
    },
    {
        "stevearc/oil.nvim",
        keys = {
            { "<space>o", vim.cmd.Oil, desc = "Oil: Open" },
        },
        opts = function()
            -- Helper function to parse output
            local function parse_output(proc)
                local result = proc:wait()
                local ret = {}

                if result.code == 0 then
                    for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
                        -- Remove trailing slash
                        line = line:gsub("/$", "")
                        ret[line] = true
                    end
                end

                return ret
            end

            -- Build git status cache
            local function new_git_status()
                return setmetatable({}, {
                    __index = function(self, key)
                        local ignore_proc = vim.system({ "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" }, {
                            cwd = key,
                            text = true,
                        })
                        local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
                            cwd = key,
                            text = true,
                        })
                        local ret = {
                            ignored = parse_output(ignore_proc),
                            tracked = parse_output(tracked_proc),
                        }

                        rawset(self, key, ret)
                        return ret
                    end,
                })
            end

            local git_status = new_git_status()

            -- Clear git status cache on refresh
            local refresh = require("oil.actions").refresh
            local orig_refresh = refresh.callback

            refresh.callback = function(...)
                git_status = new_git_status()
                orig_refresh(...)
            end

            ---@module "oil"
            ---@type oil.SetupOpts
            return {
                columns = {
                    "icon",
                    "permissions",
                    "size",
                    "mtime",
                },
                confirmation = {
                    border = defaults.ui.border.name,
                },
                float = {
                    border = defaults.ui.border.name,
                },
                keymaps_help = {
                    border = defaults.ui.border.name,
                },
                lsp_file_methods = {
                    autosave_changes = true,
                },
                progress = {
                    border = defaults.ui.border.name,
                },
                ssh = {
                    border = defaults.ui.border.name,
                },
                view_options = {
                    view_options = {
                        is_hidden_file = function(name, bufnr)
                            local dir = require("oil").get_current_dir(bufnr)
                            local is_dotfile = vim.startswith(name, ".") and name ~= ".."

                            -- If no local directory (e.g. for ssh connections), just hide dotfiles
                            if not dir then
                                return is_dotfile
                            end

                            -- Dotfiles are considered hidden unless tracked
                            if is_dotfile then
                                return not git_status[dir].tracked[name]
                            else
                                return git_status[dir].ignored[name]
                            end
                        end,
                    },
                    -- show_hidden = true,
                    sort = {
                        { "type", "asc" },
                        { "name", "asc" },
                    },
                },
                watch_for_changes = true,
            }
        end,
    },
}
