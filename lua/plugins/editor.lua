return {
    {
        "SmiteshP/nvim-navic",
        highlights = {},
        config = function(_, opts)
            hl.apply({
                { NavicIconsArray = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsBoolean = { bg = colors.gray.base, fg = colors.orange.base } },
                { NavicIconsClass = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsConstant = { bg = colors.gray.base, fg = colors.orange.base } },
                { NavicIconsConstructor = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsEnum = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsEnumMember = { bg = colors.gray.base, fg = colors.cyan.base } },
                { NavicIconsEvent = { bg = colors.gray.base, fg = colors.magenta.base } },
                { NavicIconsField = { bg = colors.gray.base, fg = colors.blue.base } },
                { NavicIconsFile = { bg = colors.gray.base, fg = colors.blue.base } },
                { NavicIconsFunction = { bg = colors.gray.base, fg = colors.magenta.base } },
                { NavicIconsInterface = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsKey = { bg = colors.gray.base, fg = colors.magenta.base } },
                { NavicIconsMethod = { bg = colors.gray.base, fg = colors.magenta.base } },
                { NavicIconsModule = { bg = colors.gray.base, fg = colors.blue.base } },
                { NavicIconsNamespace = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsNull = { bg = colors.gray.base, fg = colors.red.base } },
                { NavicIconsNumber = { bg = colors.gray.base, fg = colors.orange.base } },
                { NavicIconsObject = { bg = colors.gray.base, fg = colors.orange.base } },
                { NavicIconsOperator = { bg = colors.gray.base, fg = colors.magenta.base } },
                { NavicIconsPackage = { bg = colors.gray.base, fg = colors.orange.base } },
                { NavicIconsProperty = { bg = colors.gray.base, fg = colors.blue.base } },
                { NavicIconsString = { bg = colors.gray.base, fg = colors.green.base } },
                { NavicIconsStruct = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsTypeParameter = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsVariable = { bg = colors.gray.base, fg = colors.blue.base } },
                { NavicSeparator = { bg = colors.gray.base, fg = colors.cyan.base } },
                { NavicText = { bg = colors.gray.base, fg = colors.white.base } },
            })

            vim.g.navic_silence = true

            vim.schedule(function()
                require("nvim-navic").setup(opts)
            end)
        end,
        event = ev.LazyFile,
        opts = {
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
        -- stylua: ignore
        keys = {
            { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
            { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
            { "<leader>ft", function () require("todo-comments.fzf").todo() end, desc = "TODOs" },
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
        "MagicDuck/grug-far.nvim",
        cmd = "GrugFar",
        keys = {
            {
                "<leader>s/",
                function()
                    local grug = require("grug-far")
                    local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")

                    grug.open({
                        transient = true,
                        prefills = {
                            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
                        },
                    })
                end,
                mode = { "n", "v" },
                desc = "Search and Replace",
            },
        },
        opts = {
            debounceMs = 500,
            engine = "astgrep",
            folding = {
                enabled = false,
            },
            headerMaxWidth = 80,
            maxWorkers = 10,
            minSearchChars = 2,
            startInInsertMode = false,
            windowCreationCommand = "split",
        },
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
                    augend.hexcolor.new({}),
                    augend.semver.alias.semver,
                    augend.date.alias["%-m/%-d"],
                    augend.date.alias["%H:%M"],
                    augend.date.alias["%H:%M:%S"],
                    augend.date.alias["%Y-%m-%d"],
                    augend.date.alias["%Y/%m/%d"],
                    augend.date.alias["%m/%d"],
                    augend.constant.new({
                        elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
                    }),
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
                    }),
                    augend.constant.new({ elements = { "North", "East", "South", "West" } }),
                    augend.constant.new({ elements = { "TRUE", "FALSE" } }),
                    augend.constant.new({ elements = { "True", "False" } }),
                    augend.constant.new({ elements = { "true", "false" } }),
                    augend.constant.new({ elements = { "and", "or" } }),
                    augend.constant.new({ elements = { "And", "Or" } }),
                    augend.constant.new({ elements = { "AND", "OR" } }),
                    augend.constant.new({ elements = { "define", "undef" } }),
                    augend.constant.new({ elements = { "float64", "float32" } }),
                    augend.constant.new({ elements = { "h1", "h2", "h3", "h4", "h5", "h6" } }),
                    augend.constant.new({ elements = { "int", "int64", "int32" } }),
                    augend.constant.new({ elements = { "on", "off" } }),
                    augend.constant.new({ elements = { "On", "Off" } }),
                    augend.constant.new({ elements = { "ON", "OFF" } }),
                    augend.constant.new({ elements = { "pick", "reword", "edit", "squash", "fixup", "exec" } }),
                    augend.constant.new({ elements = { "Up", "Down", "Left", "Right" } }),
                    augend.constant.new({ elements = { "up", "down", "left", "right" } }),
                    augend.constant.new({ elements = { "yes", "no" } }),
                    augend.constant.new({ elements = { "Yes", "No" } }),
                    augend.constant.new({ elements = { "YES", "NO" } }),
                    augend.constant.new({ elements = { "&&", "||" }, word = false }),
                    augend.constant.new({ elements = { ">", "<" }, word = false }),
                    augend.constant.new({ elements = { "==", "!=" }, word = false }),
                    augend.constant.new({ elements = { "===", "!==" }, word = false }),
                    augend.constant.new({ elements = { ">=", "<=" }, word = false }),
                    augend.constant.new({ elements = { "++", "--" }, word = false }),
                    augend.user.new({
                        find = require("dial.augend.common").find_pattern("%u+"),
                        add = function(text, _, _)
                            return { text = text:lower(), cursor = #text } ---@diagnostic disable-line: redundant-return-value
                        end,
                    }),
                    augend.user.new({
                        find = require("dial.augend.common").find_pattern("%l+"),
                        add = function(text, _, _)
                            return { text = text:upper(), cursor = #text } ---@diagnostic disable-line: redundant-return-value
                        end,
                    }),
                    augend.case.new({
                        types = { "camelCase", "snake_case", "kebab-case", "PascalCase", "SCREAMING_SNAKE_CASE" },
                        cyclic = true,
                    }),
                    -- Markdown headers & check boxes.
                    augend.misc.alias.markdown_header,
                    augend.constant.new({
                        elements = { "- [ ]", "- [x]" },
                        word = false,
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
        "chrisgrieser/nvim-chainsaw",
        init = function()
            ev.on_load("which-key.nvim", function()
                vim.schedule(function()
                    -- stylua: ignore
                    local cs = function(fn) return function() require("chainsaw")[fn]() end end

                    require("which-key").add({
                        { "<leader>dl", group = "Log" },
                        { "<leader>dlc", cs("clearLogs"), desc = "Clear" },
                        { "<leader>dla", cs("allLogs"), desc = "All" },
                        { "<leader>dlm", cs("messageLog"), desc = "Message" },
                        { "<leader>dlv", cs("variableLog"), mode = { "n", "v" }, desc = "Variable" },
                        { "<leader>dlo", cs("objectLog"), desc = "Object" },
                        { "<leader>dlt", cs("timeLog"), desc = "Time" },
                        { "<leader>dld", cs("debugLog"), desc = "Debug" },
                        { "<leader>dlr", cs("removeLogs"), desc = "Remove" },
                        { "<leader>dlb", cs("beepLog"), desc = "Beep" },
                    }, { notify = false })
                end)
            end)
        end,
        opts = {},
    },
    {
        "chrisgrieser/nvim-rulebook",
        -- stylua: ignore
        keys = {
            { "<leader>ri", function() require("rulebook").ignoreRule() end, desc = "Ignore" },
            { "<leader>rl", function() require("rulebook").lookupRule() end, desc = "Look Up" },
            { "<leader>ry", function() require("rulebook").yankDiagnosticCode() end, desc = "Yank Diagnostic" },
        },
    },
}
