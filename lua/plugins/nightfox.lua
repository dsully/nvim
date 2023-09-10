-- Color scheme.
return {
    "EdenEast/nightfox.nvim",
    config = function()
        local colors = {
            -- Slightly tweaked to be more like nordic.nvim.
            red = { base = "#bf616a", bright = "#d06f79", dim = "#a54e56" },
            orange = { base = "#d08770", bright = "#d89079", dim = "#b46950" },
            green = { base = "#a3be8c", bright = "#b1d196", dim = "#8aa872" },
            yellow = { base = "#ebcb8b", bright = "#f0d399", dim = "#d9b263" },
            magenta = { base = "#b48ead", bright = "#c895bf", dim = "#9d7495" },
            pink = { base = "#bf88bc", bright = "#d092ce", dim = "#a96ca5" },

            -- Nordic: blue, intense_blue, none
            blue = { base = "#81a1c1", bright = "#5e81ac", dim = "#668aab" },

            -- Nordic: black, bright_black, dark_black
            black = { base = "#3b4252", bright = "#434c5e", dim = "#2e3440" },

            -- Nordic: cyan, bright_cyan, none
            cyan = { base = "#8fbcbb", bright = "#88c0d0", dim = "#69a7ba" },

            -- Nordic: white, bright_white, dark_white
            white = { base = "#e5e9f0", bright = "#eceff4", dim = "#d8dee9" },

            -- Noridc: gray, grayish, dark_black_alt
            gray = { base = "#4c566a", bright = "#667084", dim = "#2b303b" },
        }

        colors.comment = colors.gray.bright
        colors.bg0 = colors.black.base -- Dark bg (status line and float)
        colors.bg1 = colors.black.dim -- Default bg

        colors.bg2 = "#39404f" -- Lighter bg (color column folds)
        colors.bg3 = "#444c5e" -- Lighter bg (cursor line)
        colors.bg4 = colors.black.bright -- Conceal, border fg

        colors.fg0 = "#c7cdd9" -- Lighter fg
        colors.fg1 = colors.white.dim -- Default fg: white.base
        colors.fg2 = colors.white.base -- Darker fg (status line): cyan.bright
        colors.fg3 = colors.gray.base -- Darker fg (line numbers, fold columns)

        colors.sel0 = "#3e4a5b" -- Pop-up bg, visual selection bg
        colors.sel1 = "#4f6074" -- Pop-up selection bg, search bg

        local spec = {
            diag = {
                hint = colors.blue.bright,
            },
            diff = {
                change = colors.yellow,
                text = colors.red,
            },
            syntax = {
                attribute = colors.blue, -- Attributes
                bracket = colors.blue, -- Brackets and Punctuation
                builtin0 = colors.blue, -- Builtin variable
                builtin1 = colors.cyan, -- Builtin type
                builtin2 = colors.blue, -- Builtin const
                comment = colors.comment, -- Comment
                conditional = colors.blue.bright, -- Conditional and loop
                const = colors.white.dim, -- Constants, imports and booleans
                dep = colors.fg3, -- Deprecated
                field = colors.blue, -- Field
                func = colors.white.bright, -- Functions and Titles
                ident = colors.white, -- Identifiers
                keyword = colors.blue, -- Keywords
                namespace = colors.cyan, -- Namespaces
                number = colors.magenta, -- Numbers
                operator = colors.blue, -- Operators
                preproc = colors.blue.bright, -- PreProc
                regex = colors.gray.bright, -- Regex
                statement = colors.blue, -- Statements
                string = colors.green, -- Strings
                type = colors.cyan, -- Types
                variable = colors.white.dim, -- Variables
            },

            -- My own specs for nvim-cmp and navic.
            lsp = {
                Array = colors.yellow,
                Boolean = colors.orange,
                Class = colors.yellow,
                Constant = colors.orange,
                Constructor = colors.yellow,
                Enum = colors.yellow,
                EnumMember = colors.cyan,
                Event = colors.magenta,
                Field = colors.blue,
                File = colors.blue,
                Function = colors.magenta,
                Interface = colors.yellow,
                Key = colors.magenta,
                Method = colors.magenta,
                Module = colors.blue,
                Namespace = colors.yellow,
                Null = colors.red,
                Number = colors.orange,
                Object = colors.orange,
                Operator = colors.magenta,
                Package = colors.orange,
                Property = colors.blue,
                String = colors.green,
                Struct = colors.yellow,
                TypeParameter = colors.yellow,
                Variable = colors.blue,
            },
        }

        local groups = {
            -- Override some default Nordfox colors.
            DiagnosticVirtualTextError = { link = "DiagnosticError" },
            DiagnosticVirtualTextWarn = { link = "DiagnosticWarn" },
            DiagnosticVirtualTextInfo = { link = "DiagnosticInfo" },
            DiagnosticVirtualTextHint = { link = "DiagnosticHint" },

            -- Editor changes.
            MatchParen = { fg = colors.cyan.bright, bg = colors.gray, style = "NONE" },
            ModeMsg = { fg = colors.white.dim },
            MoreMsg = { fg = colors.cyan.bright },
            StatusLine = { fg = colors.cyan.bright, bg = colors.gray },

            -- Syntax
            Constant = { fg = spec.const },

            healthError = { fg = colors.red, bg = "NONE" },
            healthSuccess = { fg = colors.green, bg = "NONE" },
            healthWarning = { fg = colors.yellow, bg = "NONE" },

            -- Treesitter
            ["@attribute"] = { fg = spec.syntax.attribute },
            ["@constructor"] = { fg = spec.syntax.ident, style = "italic" },
            ["@exception"] = { fg = spec.syntax.builtin0 },
            ["@field.rust"] = { fg = spec.syntax.builtin0 },
            ["@function.macro"] = { fg = spec.syntax.builtin0, style = "italic" },
            ["@namespace"] = { fg = spec.syntax.namespace, style = "italic" },
            ["@parameter"] = { fg = colors.yellow, style = "italic" },
            ["@punctuation.special"] = { fg = colors.blue },
            ["@repeat"] = { fg = colors.blue, style = "italic" },
            ["@string.regex"] = { fg = spec.syntax.regex },
            ["@text.emphasis"] = { fg = colors.white.dim, style = "italic" },
            ["@text.note"] = { fg = colors.orange, bg = "NONE" },
            ["@text.strong"] = { fg = colors.white.dim, style = "bold" },
            ["@text.todo"] = { fg = colors.orange, bg = "NONE" },
            ["@text.uri"] = { fg = spec.syntax.const, style = "NONE" },

            -- Ignore semantic token highlighting for comments so the tree-sitter comment parser can work.
            ["@lsp.type.comment.lua"] = { fg = "NONE", style = "NONE" },
            ["@lsp.type.typeParameter"] = { link = "@parameter" },

            CmpDocumentation = { fg = colors.white },
            CmpDocumentationBorder = { fg = colors.gray.bright },
            CmpGhostText = { link = "Comment" },
            CmpItemAbbr = { fg = colors.white.dim },
            CmpItemKindDefault = { fg = colors.white.dim },

            CmpItemMenu = { fg = colors.magenta },
            CmpItemKindClass = { fg = spec.lsp.Class },
            CmpItemKindConstant = { fg = spec.lsp.Constant },
            CmpItemKindConstructor = { fg = spec.lsp.Constructor },
            CmpItemKindEnum = { fg = spec.lsp.Enum },
            CmpItemKindEnumMember = { fg = spec.lsp.EnumMember },
            CmpItemKindEvent = { fg = spec.lsp.Event },
            CmpItemKindField = { fg = spec.lsp.Field },
            CmpItemKindFunction = { fg = spec.lsp.Function },
            CmpItemKindInterface = { fg = spec.lsp.Interface },
            CmpItemKindKeyword = { fg = spec.lsp.Key },
            CmpItemKindMethod = { fg = spec.lsp.Method },
            CmpItemKindModule = { fg = spec.lsp.Module },
            CmpItemKindOperator = { fg = spec.lsp.Operator },
            CmpItemKindProperty = { fg = spec.lsp.Property },
            CmpItemKindReference = { fg = spec.lsp.Key },
            CmpItemKindSnippet = { fg = spec.fg2 },
            CmpItemKindStruct = { fg = spec.lsp.Struct },
            CmpItemKindTypeParameter = { fg = spec.lsp.TypeParameter },
            CmpItemKindUnit = { fg = spec.lsp.Key },
            CmpItemKindValue = { fg = spec.lsp.Variable },
            CmpItemKindVariable = { fg = spec.lsp.Variable },

            CodewindowAddition = { fg = colors.green },
            CodewindowBorder = { fg = colors.gray },
            CodewindowDeletion = { fg = colors.red },

            -- dressing.nvim
            FloatTitle = { fg = colors.white.bright },

            FidgetTitle = { fg = colors.white.bright },
            FidgetTask = { fg = colors.blue.bright },

            LuasnipChoiceNodePassive = { style = "italic" },
            LuasnipChoiceNodeActive = { style = "bold" },

            NavicIconsArray = { fg = spec.lsp.Array, bg = colors.gray },
            NavicIconsBoolean = { fg = spec.lsp.Boolean, bg = colors.gray },
            NavicIconsClass = { fg = spec.lsp.Class, bg = colors.gray },
            NavicIconsConstant = { fg = spec.lsp.Constant, bg = colors.gray },
            NavicIconsConstructor = { fg = spec.lsp.Constructor, bg = colors.gray },
            NavicIconsEnum = { fg = spec.lsp.Enum, bg = colors.gray },
            NavicIconsEnumMember = { fg = spec.lsp.EnumMember, bg = colors.gray },
            NavicIconsEvent = { fg = spec.lsp.Event, bg = colors.gray },
            NavicIconsField = { fg = spec.lsp.Field, bg = colors.gray },
            NavicIconsFile = { fg = spec.lsp.File, bg = colors.gray },
            NavicIconsFunction = { fg = spec.lsp.Function, bg = colors.gray },
            NavicIconsInterface = { fg = spec.lsp.Interface, bg = colors.gray },
            NavicIconsKey = { fg = spec.lsp.Key, bg = colors.gray },
            NavicIconsMethod = { fg = spec.lsp.Method, bg = colors.gray },
            NavicIconsModule = { fg = spec.lsp.Module, bg = colors.gray },
            NavicIconsNamespace = { fg = spec.lsp.Namespace, bg = colors.gray },
            NavicIconsNull = { fg = spec.lsp.Null, bg = colors.gray },
            NavicIconsNumber = { fg = spec.lsp.Number, bg = colors.gray },
            NavicIconsObject = { fg = spec.lsp.Object, bg = colors.gray },
            NavicIconsOperator = { fg = spec.lsp.Operator, bg = colors.gray },
            NavicIconsPackage = { fg = spec.lsp.Package, bg = colors.gray },
            NavicIconsProperty = { fg = spec.lsp.Property, bg = colors.gray },
            NavicIconsString = { fg = spec.lsp.String, bg = colors.gray },
            NavicIconsStruct = { fg = spec.lsp.Struct, bg = colors.gray },
            NavicIconsTypeParameter = { fg = spec.lsp.TypeParameter, bg = colors.gray },
            NavicIconsVariable = { fg = spec.lsp.Variable, bg = colors.gray },
            NavicSeparator = { fg = colors.cyan, bg = colors.gray },
            NavicText = { fg = colors.white, bg = colors.gray },

            NonText = { fg = colors.white },
            NormalFloat = { bg = colors.bg1 },

            NoiceFormatProgressDone = { fg = colors.white.bright, bg = colors.bg1 },
            NoiceFormatProgressTodo = { fg = colors.white.bright, bg = colors.bg1 },

            NoiceLspProgressClient = { fg = colors.blue },
            NoiceLspProgressSpinner = { fg = colors.cyan.bright },

            NoiceLspProgressTitle = { fg = colors.white.bright },

            TelescopeBorder = { fg = colors.gray.base, bg = colors.gray.dim },
            TelescopeNormal = { fg = colors.white.dim, bg = colors.gray.dim },
            TelescopePreviewNormal = { link = "TelescopeNormal" },
            TelescopePromptPrefix = { fg = colors.white.dim },
            TelescopeSelection = { fg = colors.cyan.bright, bg = colors.gray, style = "bold" },
            TelescopeMatching = { fg = colors.cyan.bright, bg = colors.gray },

            Terminal = { fg = colors.white.dim, bg = colors.gray.dim },

            UnderlinedTitle = { style = "bold,underline" },
        }

        local options = {
            dim_inactive = false,
            module_default = true,
            transparent = false,
            styles = {
                comments = "italic",
                conditionals = "italic",
                constants = "NONE",
                functions = "italic",
                keywords = "italic",
                numbers = "NONE",
                operators = "NONE",
                strings = "NONE",
                types = "italic",
                variables = "NONE",
            },
            -- Inverse highlight for different types
            inverse = {
                match_paren = false,
                visual = false,
                search = false,
            },
            modules = {
                alpha = true,
                dap_ui = true,
                gitsigns = true,
                lsp_semantic_tokens = true,
                lsp_trouble = true,
                mini = true,
                native_lsp = {
                    enable = true,
                    background = false,
                },
                neotest = true,
                notify = true,
            },
        }

        require("nightfox").setup({
            options = options,
            palettes = { nordfox = colors },
            specs = { nordfox = spec },
            groups = { nordfox = groups },
        })

        vim.cmd.colorscheme("nordfox")

        vim.api.nvim_create_autocmd("BufWritePost", {
            desc = "Load nightfox config on write.",
            pattern = "*/nightfox.lua",
            callback = function(args)
                vim.cmd.source(args.file)
                vim.cmd.NightfoxCompile()
                vim.notify("Compiled Nightfox Colorscheme...")
            end,
        })
    end,
    lazy = false,
    priority = 1000,
}
