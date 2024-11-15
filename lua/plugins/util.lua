return {
    { "nvim-lua/plenary.nvim" },
    { "MunifTanjim/nui.nvim" },
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
            ev.on({ ev.BufReadPost, ev.BufNewFile }, function(args)
                vim.schedule(function()
                    require("chezmoi.commands.__edit").watch(args.buf)
                end)
            end, {
                pattern = { vim.env.XDG_DATA_HOME .. "/chezmoi/*" },
            })

            -- Watch chezmoi files for changes in the target-path, and add them.
            vim.schedule(function()
                local ok, targets = pcall(require("chezmoi.commands").list, { args = { "--include", "files", "--path-style", "absolute" } })

                if ok then
                    ev.on(ev.BufWritePost, function(args)
                        notify.info("chezmoi: Adding changes to: " .. args.file)

                        require("chezmoi.commands.__base").execute({
                            cmd = "add",
                            args = { args.file },
                        })
                    end, {
                        desc = "Apply chezmoi changes via 'chezmoi edit'",
                        pattern = targets,
                    })
                end
            end)

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
        "stevearc/profile.nvim",
        cond = vim.env.NVIM_PROFILE or false,
        config = function()
            require("profile").instrument_autocmds()

            if os.getenv("NVIM_PROFILE"):lower():match("^start") then
                require("profile").start("*")
            else
                require("profile").instrument("*")
            end

            vim.keymap.set("", "<c-p>", function()
                local prof = require("profile")
                if prof.is_recording() then
                    prof.stop()

                    vim.ui.input({ prompt = "Save profile to:", completion = "file", default = "profile.json" }, function(filename)
                        if filename then
                            prof.export(filename)
                            notify.info("Wrote profile to: " .. filename)
                        end
                    end)
                else
                    prof.start("*")
                end
            end)
        end,
        lazy = false,
        priority = 999,
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            bigfile = { enabled = true },
            notifier = {
                enabled = true,
                timeout = 3000,
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
                terminal = defaults.ui.float,
                win = defaults.ui.float,
            },
            words = { enabled = true },
        },
        -- stylua: ignore
        keys = {
            ---@diagnostic disable-next-line: param-type-mismatch
            { "<leader>nd", function() require("snacks").notifier:hide() end, desc = "Notification: Dismiss" },
            { "]]", function() require("snacks").words.jump(vim.v.count1) end, desc = "snacks: goto next reference" },
            { "[[", function() require("snacks").words.jump(-vim.v.count1) end, desc = "snacks: goto prev reference" },

            { [[<C-\>]], function() require("snacks").terminal.toggle(vim.env.SHELL) end, mode = { "n", "t" }, desc = "Terminal" },
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
                end,
            })

            hl.apply({
                { SnacksNormal = { link = "Normal" } },
                { SnacksBackdrop = { link = "Normal" } },

                { SnacksNotifierTrace = { fg = colors.gray.base } },
                { SnacksNotifierIconTrace = { link = "SnacksNotifierTrace" } },
                { SnacksNotifierBorderTrace = { fg = colors.white.bright } },

                { SnacksNotifierDebug = { fg = colors.white.base } },
                { SnacksNotifierIconDebug = { link = "SnacksNotifierDebug" } },
                { SnacksNotifierBorderDebug = { fg = colors.white.bright } },

                { SnacksNotifierInfo = { fg = colors.cyan.base } },
                { SnacksNotifierIconInfo = { link = "SnacksNotifierInfo" } },
                { SnacksNotifierBorderInfo = { fg = colors.white.bright } },

                { SnacksNotifierWarn = { fg = colors.yellow.base } },
                { SnacksNotifierIconWarn = { link = "SnacksNotifierWarn" } },
                { SnacksNotifierBorderWarn = { fg = colors.white.bright } },

                { SnacksNotifierError = { fg = colors.red.base } },
                { SnacksNotifierIconError = { link = "SnacksNotifierError" } },
                { SnacksNotifierBorderError = { fg = colors.white.bright } },
            })
        end,
    },
}
