---@type LazySpec[]
return {
    {
        "SmiteshP/nvim-navic",
        highlights = {
            NavicIconsArray = { bg = colors.gray.base, fg = colors.yellow.base },
            NavicIconsBoolean = { bg = colors.gray.base, fg = colors.orange.base },
            NavicIconsClass = { bg = colors.gray.base, fg = colors.yellow.base },
            NavicIconsConstant = { bg = colors.gray.base, fg = colors.orange.base },
            NavicIconsConstructor = { bg = colors.gray.base, fg = colors.yellow.base },
            NavicIconsEnum = { bg = colors.gray.base, fg = colors.yellow.base },
            NavicIconsEnumMember = { bg = colors.gray.base, fg = colors.cyan.base },
            NavicIconsEvent = { bg = colors.gray.base, fg = colors.magenta.base },
            NavicIconsField = { bg = colors.gray.base, fg = colors.blue.base },
            NavicIconsFile = { bg = colors.gray.base, fg = colors.blue.base },
            NavicIconsFunction = { bg = colors.gray.base, fg = colors.magenta.base },
            NavicIconsInterface = { bg = colors.gray.base, fg = colors.yellow.base },
            NavicIconsKey = { bg = colors.gray.base, fg = colors.magenta.base },
            NavicIconsMethod = { bg = colors.gray.base, fg = colors.magenta.base },
            NavicIconsModule = { bg = colors.gray.base, fg = colors.blue.base },
            NavicIconsNamespace = { bg = colors.gray.base, fg = colors.yellow.base },
            NavicIconsNull = { bg = colors.gray.base, fg = colors.red.base },
            NavicIconsNumber = { bg = colors.gray.base, fg = colors.orange.base },
            NavicIconsObject = { bg = colors.gray.base, fg = colors.orange.base },
            NavicIconsOperator = { bg = colors.gray.base, fg = colors.magenta.base },
            NavicIconsPackage = { bg = colors.gray.base, fg = colors.orange.base },
            NavicIconsProperty = { bg = colors.gray.base, fg = colors.blue.base },
            NavicIconsString = { bg = colors.gray.base, fg = colors.green.base },
            NavicIconsStruct = { bg = colors.gray.base, fg = colors.yellow.base },
            NavicIconsTypeParameter = { bg = colors.gray.base, fg = colors.yellow.base },
            NavicIconsVariable = { bg = colors.gray.base, fg = colors.blue.base },
            NavicSeparator = { bg = colors.gray.base, fg = colors.cyan.base },
            NavicText = { bg = colors.gray.base, fg = colors.white.base },
        },
        init = function()
            vim.g.navic_silence = true

            vim.schedule(function()
                ---@param client vim.lsp.Client
                ---@param buffer number
                nvim.lsp.on_supports_method("textDocument/documentSymbol", function(client, buffer)
                    require("nvim-navic").attach(client, buffer)
                end)
            end)
        end,
        opts = {
            click = true,
            highlight = true,
            lazy_update_context = true,
            lsp = {
                auto_attach = true,
                preference = { "basedpyright" },
            },
        },
    },
    {
        "folke/todo-comments.nvim",
        event = ev.LazyFile,
        keys = {
            -- stylua: ignore start
            { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
            { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },

            { "<leader>ft", function() Snacks.picker.todo_comments() end, desc = "TODOs" },
            { "<leader>fT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
            -- stylua: ignore end
        },
        opts = {
            highlight = {
                -- https://github.com/folke/todo-comments.nvim/pull/199
                keyword = "bg",
                pattern = [[.{-}<(\s?(KEYWORDS):)]],
                -- pattern = [[(KEYWORDS)\s*(\([^\)]*\))?:]],
            },
            keywords = {
                BUG = { icon = "🐛", color = "error", alt = { "BROKEN", "FIXME", "ISSUE" } },
                HACK = { icon = "🔥", color = "warning" },
                IDEA = { icon = "💡", color = "test" },
                NOTE = { icon = "ℹ️", color = "hint", alt = { "INFO" } },
                TEST = { icon = "🧪", color = "test", alt = { "EXPERIMENT", "TESTING" } },
                TODO = { icon = "✅", color = "info" },
                WARN = { icon = "⚠️", color = "warning", alt = { "WARNING", "XXX" } },
                NB = { icon = "󰴄 ", color = "info" },
            },
        },
    },
    {
        "folke/trouble.nvim",
        cmd = { "Trouble" },
        keys = {
            -- stylua: ignore
            { "<leader>xx", function() require("trouble").toggle("diagnostics") end, desc = "Trouble" },
        },
        opts = {
            auto_preview = false,
            focus = true,
            modes = {
                lsp_references = {
                    params = {
                        include_declaration = false,
                    },
                },
            },
        },
    },
    {
        "dsully/search-and-replace.nvim",
        cmd = { "SearchAndReplace" },
        config = function()
            nvim.command("SearchAndReplace", function(opts)
                local args = vim.tbl_map(vim.trim, vim.split(opts.args, "%s+", { trimempty = true }))
                local search = ""
                local replace = ""
                local glob = "*"

                if opts.range > 0 then
                    replace, glob = args[1], args[2]

                    search = vim.trim(table.concat(nvim.buffer.visual_selection(), "\n"))
                else
                    search, replace, glob = args[1], args[2], args[3]
                end

                if not search or not replace then
                    vim.notify("Search string and replacement string are required.", vim.log.levels.ERROR)
                    return
                end

                local cmd = string.format(
                    "fd --print0 --type f --glob '%s' | sad --read0 --fzf '%s' '%s' '%s'",
                    glob,
                    "\\--height=100% --border=none --preview-window=up,50%,wrap,border-bottom,+{2}/3",
                    search,
                    replace
                )

                local terminal = Snacks.terminal.open(cmd, { auto_close = false, cwd = nvim.file.cwd() })

                if terminal then
                    terminal:on("TermClose", function()
                        if type(vim.v.event) == "table" then
                            local exit_code = vim.v.event.status

                            if exit_code ~= 0 and exit_code ~= 130 then
                                vim.notify("Search and replace exited with code: " .. exit_code, vim.log.levels.WARN)
                                return
                            end
                        end

                        terminal:close()
                        vim.cmd.checktime()
                    end, { buf = true })
                end
            end, {
                nargs = "+",
                range = true,
                desc = "Search and Replace",
            })
        end,
        virtual = true,
    },
    {
        "monaqa/dial.nvim",
        config = function()
            local augend = require("dial.augend")

            require("dial.config").augends:register_group({
                default = {
                    augend.integer.alias.decimal,
                    augend.integer.alias.hex,
                    augend.integer.alias.octal,
                    augend.integer.alias.binary,
                    augend.hexcolor.new(),
                    augend.semver.alias.semver,
                    augend.date.alias["%-m/%-d"],
                    augend.date.alias["%H:%M"],
                    augend.date.alias["%H:%M:%S"],
                    augend.date.alias["%Y-%m-%d"],
                    augend.date.alias["%Y/%m/%d"],
                    augend.date.alias["%m/%d"],
                    augend.constant.alias.en_weekday_full,
                    augend.constant.new({
                        elements = {
                            "January",
                            "February",
                            "March",
                            "April",
                            "May",
                            "June",
                            "July",
                            "August",
                            "September",
                            "October",
                            "November",
                            "December",
                        },
                        preserve_case = true,
                    }),
                    augend.constant.new({ elements = { "North", "East", "South", "West" }, preserve_case = true }),
                    augend.constant.new({ elements = { "true", "false" }, preserve_case = true }),
                    augend.constant.new({ elements = { "and", "or" }, preserve_case = true }),
                    augend.constant.new({ elements = { "define", "undef" } }),
                    augend.constant.new({ elements = { "float64", "float32" } }),
                    augend.constant.new({ elements = { "h1", "h2", "h3", "h4", "h5", "h6" } }),
                    augend.constant.new({ elements = { "int", "int64", "int32" } }),
                    augend.constant.new({ elements = { "on", "off" }, preserve_case = true }),
                    augend.constant.new({ elements = { "pick", "reword", "edit", "squash", "fixup", "exec" } }),
                    augend.constant.new({ elements = { "up", "down", "left", "right" }, preserve_case = true }),
                    augend.constant.new({ elements = { "yes", "no" }, preserve_case = true }),
                    augend.constant.new({ elements = { "&&", "||" }, word = false }),
                    augend.constant.new({ elements = { ">", "<" }, word = false }),
                    augend.constant.new({ elements = { "==", "!=" }, word = false }),
                    augend.constant.new({ elements = { "===", "!==" }, word = false }),
                    augend.constant.new({ elements = { ">=", "<=" }, word = false }),
                    augend.constant.new({ elements = { "++", "--" }, word = false }),
                    augend.user.new({
                        find = require("dial.augend.common").find_pattern("%u+"),
                        add = function(text, _, _)
                            return { text = text:lower(), cursor = #text }
                        end,
                    }),
                    augend.user.new({
                        find = require("dial.augend.common").find_pattern("%l+"),
                        add = function(text, _, _)
                            return { text = text:upper(), cursor = #text }
                        end,
                    }),
                    augend.case.new({
                        ---@diagnostic disable-next-line: assign-type-mismatch
                        types = { "camelCase", "snake_case", "kebab-case", "PascalCase", "SCREAMING_SNAKE_CASE" },
                        cyclic = true,
                    }),
                    -- Markdown headers & check boxes.
                    augend.misc.alias.markdown_header,
                    augend.constant.new({
                        elements = { "[ ]", "[x]" },
                        word = false,
                        cyclic = true,
                    }),
                },
            })
        end,
        -- stylua: ignore
        keys = {
            { "<C-Up>", function() return require("dial.map").inc_normal() end, desc = "Increment Pattern", expr = true },
            { "<C-Down>", function() return require("dial.map").dec_normal() end, desc = "Decrement Pattern", expr = true },
        },
    },
    {
        "Goose97/timber.nvim",
        keys = {
            -- stylua: ignore start
            { "<leader>dlj", desc = "Insert Below" },
            { "<leader>dlk", desc = "Insert Above" },
            { "<leader>dlc", function() require("timber.actions").clear_log_statements({ global = false }) end, desc = "Clear" },
            { "<leader>dlf", function() return require("timber.buffers").open_float({ sort = "newest_first" }) end, desc = "Open Float" },
            { "<leader>dlS", function() require("timber.summary").open({ focus = true }) end, desc = "Summary" },
            { "<leader>dlt", function() require("timber.actions").toggle_comment_log_statements({ global = false }) end, desc = "Toggle" },
            { "<leader>dlT", function() require("timber.actions").toggle_comment_log_statements({ global = true }) end, desc = "Toggle: Global" },
            -- stylua: ignore end
            {
                "<leader>dls",
                function()
                    require("timber.actions").insert_log({
                        templates = { before = "default", after = "default" },
                        position = "surround",
                    })
                end,
                desc = "Log Surround",
            },
        },
        ---@module 'timber'
        ---@type Timber.Config
        opts = {
            default_keymaps_enabled = false,
            highlight = {
                on_insert = true,
                duration = 100,
            },
            keymaps = {
                insert_log_below = "<leader>dlj",
                insert_log_above = "<leader>dlk",
            },
            log_templates = {
                default = {
                    bash = [[echo "%log_marker: %log_target: ${%log_target}"]],
                    c = [[printf("%log_marker: %log_target: %s\n", %log_target);]],
                    cpp = [[std::cout << "%log_marker: %log_target: " << %log_target << std::endl;]],
                    go = [[log.Printf("%log_marker: %log_target: %v\n", %log_target)]],
                    java = [[System.out.println("%log_marker: %log_target: " + %log_target);]],
                    javascript = [[console.log("%log_marker: %log_target", %log_target)]],
                    jsx = [[console.log("%log_marker: %log_target", %log_target)]],
                    lua = [[print("%log_marker: %log_target", %log_target)]],
                    python = [[print("%log_marker: %log_target", %log_target)]],
                    rust = [[println!("%log_marker: %log_target: {%log_target:#?}");]],
                    tsx = [[console.log("%log_marker: %log_target", %log_target)]],
                    typescript = [[console.log("%log_marker: %log_target", %log_target)]],
                },
            },
        },
    },
}
