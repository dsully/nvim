local copilot = " "

local M = {
    ai_file_types = {
        "bash",
        "c",
        "cpp",
        "fish",
        "go",
        "html",
        "java",
        "javascript",
        "just",
        "lua",
        "python",
        "rust",
        "sh",
        "typescript",
        "zsh",
    },

    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },

    cmp = {
        backend = "nvim-cmp",
        kind = {
            calc = "󰃬",
            fish = "󰌋",
        },
        menu = {
            async_path = " [Path]",
            buffer = " [Buffer]",
            calc = "󰃬 [Calc]",
            cmdline = "󰘳 [Command]",
            crates = " [󱘗 Crates]",
            copilot = copilot .. "[Copilot]",
            env = " [ENV]",
            fish = "󰈺 [Fish]",
            luasnip = " [LuaSnip]",
            snippets = " [Snippets]",
            nvim_lsp = " [LSP]",
            path = " [Path]",
        },
        symbols = {
            Copilot = copilot,
            Snippet = "",
            Version = "󱘗", -- crates.nvim lsp completion type.
        },
    },

    files = {
        ignored_patterns = {
            "%.DS_Store",
            "%.gz",
            "%.jpeg",
            "%.jpg",
            "%.lock",
            "%.png",
            "%.yarn/.*",
            "^.direnv/.*",
            "^.git/",
            "^.venv/.*",
            "^__pypackages__/.*",
            "^lazy-lock.json",
            "^site-packages/",
            "^target/",
            "^venv/.*",
            "node%_modules/.*",
        },
    },

    -- Filetypes that should be formatted on save.
    formatting = {
        file_types = {
            bash = { "shellharden", "shfmt" },
            bzl = { "buildifier" },
            caddy = { "caddy" },
            direnv = { "shellharden", "shfmt" },
            fish = { "fish_indent" },
            go = { "goimports", "gofumpt" },
            javascript = { "biome" },
            just = { "just" },
            lua = { "stylua" },
            markdown = { "markdownlint" },
            rust = {},
            sh = { "shellharden", "shfmt" },
            toml = { "taplo" },
            typescript = { "biome" },
        },
        on_save = {
            "bash",
            "caddy",
            "direnv",
            "fish",
            "go",
            "just",
            "lua",
            "rust",
            "toml",
        },
    },

    linters = {
        fish = { "fish" },
        ghaction = { "actionlint" },
        gitcommit = { "write_good" },
        go = { "revive" },
        htmldjango = { "curlylint" },
        jinja = { "curlylint" },
        markdown = { "markdownlint", "write_good" },
        protobuf = { "protolint" },
        rst = { "rstcheck", "write_good" },
        text = { "write_good" },
        yaml = { "yamllint" },
    },

    tools = {
        "actionlint",
        "biome",
        "curlylint",
        "gitui",
        "gofumpt",
        "goimports",
        "markdownlint",
        "protolint",
        "revive",
        "rstcheck",
        "shellharden",
        "shfmt",
        "stylua",
        "write-good",
        "yamllint",
    },

    icons = {
        actions = {
            close = "󰅖",
            close_box = "󰅗",
            close_hexagon = "󰅜",
            close_outline = "󰅚",
            close_round = "󰅙",
        },

        diagnostics = {
            error = "󰞏", --
            warn = "", -- "",--
            hint = "󱐌", --"󰮔", -- 󱐌
            info = "",
            -- error = "󰅚 ",
            -- warn = "󰀪 ",
            -- info = " ",
            -- hint = "󰌶 ",
        },

        fold = {
            open = "",
            closed = "",
        },

        menu = {
            actions = {
                outline = {
                    left = "󰨂",
                    right = "󰨃",
                    up = "󰚷",
                    down = "󰚶",
                    swap = "󰩥",
                    filter = "󱃦",
                },
                filled = {
                    up = "󰍠",
                    down = "󰍝",
                    left = "󰍞",
                    right = "󰍟",
                    swap = "󰩤",
                    filter = "󱃥",
                },
            },
            hamburger = "󰍜",
            hamburger_open = "󰮫",
        },

        misc = {
            circle = "",
            circle_filled = "",
            circle_slash = "",
            copilot = copilot,
            datetime = "󱛡 ",
            ellipse = "…",
            ellipse_dbl = "",
            hook = "󰛢",
            hook_disabled = "󰛣",
            kebab = "",
            lightbulb = "󰌶",
            modified = "●",
            newline = "",
        },

        separators = {
            angle_quote = {
                left = "«",
                right = "»",
            },
            chevron = {
                left = "",
                right = "",
                down = "",
            },
            circle = {
                left = "",
                right = "",
            },
            arrow = {
                left = "",
                right = "",
            },
            slant = {
                left = "",
                right = "",
            },
            bar = {
                left = "⎸",
                right = "⎹",
            },
        },
    },

    -- Various buffer and file types that should be ignored.
    ignored = {
        buffer_types = {
            "gitcommit",
            "help",
            "nofile",
            "quickfix",
            "terminal",
            "trouble",
        },
        file_types = {
            "Codewindow",
            "DressingInput",
            "DressingSelect",
            "TelescopePrompt",
            "TelescopeResults",
            "alpha",
            "chatgpt",
            "chatgpt-input",
            "checkhealth",
            "cmp_menu",
            "git",
            "gitrebase",
            "glowpreview",
            "keymenu",
            "lazy",
            "log",
            "lspinfo",
            "mason",
            "noice",
            "notify",
            "qf",
            "trouble",
            "tsplayground",
            "vim",
        },
        lsp = {
            "copilot",
            "llm-ls",
            "typos_lsp",
        },
        paths = {
            "~/.cache",
            "~/.cargo",
            "~/.local/state",
            "~/.rustup",
            tostring(vim.fn.stdpath("data")),
            tostring(vim.fn.stdpath("state")),
        },
        progress = {
            "copilot",
            "ltex",
            "pylance",
            "pyright",
        },
    },

    root_patterns = {
        ".chezmoiroot",
        ".neoconf.json",
        ".neoconf.jsonc",
        ".stylua.toml",
        "configure",
        "package.json",
        "pyproject.toml",
        "requirements.txt",
        "ruff.toml",
        "selene.toml",
        "setup.cfg",
        "setup.py",
        "stylua.toml",
        "Cargo.toml",
    },

    statusline = {
        modes = {
            ["n"] = "N",
            ["no"] = "N",
            ["nov"] = "N",
            ["noV"] = "N",
            ["no"] = "N",
            ["niI"] = "N",
            ["niR"] = "N",
            ["niV"] = "N",
            ["v"] = "V",
            ["V"] = "V",
            [""] = "V",
            ["s"] = "S",
            ["S"] = "S",
            [""] = "S",
            ["i"] = "I",
            ["ic"] = "I",
            ["ix"] = "I",
            ["R"] = "R",
            ["Rc"] = "R",
            ["Rv"] = "R",
            ["Rx"] = "R",
            ["r"] = "R",
            ["rm"] = "R",
            ["r?"] = "R",
            ["c"] = "C",
            ["cv"] = "C",
            ["ce"] = "C",
            ["!"] = "T",
            ["t"] = "T",
            ["nt"] = "T",
        },

        wordcount = {
            markdown = true,
            text = true,
            vimwiki = true,
        },
    },
}

M.colors = {
    -- Slightly tweaked to be more like nordic.nvim.
    red = { base = "#bf616a", bright = "#d06f79", dim = "#a54e56" },
    orange = { base = "#d08770", bright = "#d89079", dim = "#b46950" },
    green = { base = "#a3be8c", bright = "#b1d196", dim = "#8aa872" },
    yellow = { base = "#ebcb8b", bright = "#f0d399", dim = "#d9b263" },
    magenta = { base = "#b48ead", bright = "#c895bf", dim = "#9d7495" },

    -- Nordic: blue, intense_blue, none
    blue = { base = "#81a1c1", bright = "#5e81ac", dim = "#668aab" },

    -- Nordic: black, bright_black, dark_black
    black = { base = "#3b4252", bright = "#434c5e", dim = "#2e3440", dark = "#222730" },

    -- Nordic: cyan, bright_cyan, none
    cyan = { base = "#8fbcbb", bright = "#88c0d0", dim = "#69a7ba" },

    -- Nordic: white, bright_white, dark_white
    white = { base = "#e5e9f0", bright = "#eceff4", dim = "#d8dee9" },

    -- Nordic: gray, grayish, dark_black_alt
    gray = { base = "#4c566a", bright = "#667084", dim = "#2b303b" },
}

M.highlights = {
    Added = { fg = M.colors.green.base },
    AlphaHeader = { fg = M.colors.blue.bright },
    AlphaFooter = { fg = M.colors.blue.base },
    Bold = { bold = true },
    Boolean = { link = "Number" },
    Changed = { fg = M.colors.blue.base },
    Character = { link = "String" },
    CmpDocumentation = { bg = M.colors.black.base, fg = M.colors.white.base },
    CmpDocumentationBorder = { bg = M.colors.black.base, fg = M.colors.gray.bright },
    CmpGhostText = { link = "Comment" },
    CmpItemAbbr = { fg = M.colors.white.dim },
    CmpItemAbbrDeprecated = { fg = M.colors.gray.base, strikethrough = true },
    CmpItemAbbrMatch = { bold = true, fg = M.colors.blue.base },
    CmpItemAbbrMatchFuzzy = { bold = true, fg = M.colors.blue.base },
    CmpItemKind = { fg = M.colors.white.bright },
    CmpItemKindClass = { fg = M.colors.yellow.base },
    CmpItemKindColor = { link = "CmpItemKind" },
    CmpItemKindConstant = { fg = M.colors.orange.base },
    CmpItemKindConstructor = { fg = M.colors.yellow.base },
    CmpItemKindEnum = { fg = M.colors.yellow.base },
    CmpItemKindEnumMember = { fg = M.colors.cyan.base },
    CmpItemKindEvent = { fg = M.colors.magenta.base },
    CmpItemKindField = { fg = M.colors.blue.base },
    CmpItemKindFile = { link = "CmpItemKind" },
    CmpItemKindFolder = { link = "CmpItemKind" },
    CmpItemKindFunction = { fg = M.colors.magenta.base },
    CmpItemKindInterface = { fg = M.colors.yellow.base },
    CmpItemKindKeyword = { fg = M.colors.magenta.base },
    CmpItemKindMethod = { fg = M.colors.magenta.base },
    CmpItemKindModule = { fg = M.colors.blue.base },
    CmpItemKindOperator = { fg = M.colors.magenta.base },
    CmpItemKindProperty = { fg = M.colors.blue.base },
    CmpItemKindReference = { fg = M.colors.magenta.base },
    CmpItemKindSnippet = { fg = M.colors.white.base },
    CmpItemKindStruct = { fg = M.colors.yellow.base },
    CmpItemKindText = { link = "CmpItemKind" },
    CmpItemKindTypeParameter = { fg = M.colors.yellow.base },
    CmpItemKindUnit = { fg = M.colors.magenta.base },
    CmpItemKindValue = { fg = M.colors.blue.base },
    CmpItemKindVariable = { fg = M.colors.blue.base },
    CmpItemMenu = { fg = M.colors.magenta.base },
    ColorColumn = { bg = M.colors.black.dim },
    Comment = { fg = M.colors.gray.bright },
    Conceal = { fg = M.colors.black.bright },
    Conditional = { fg = M.colors.blue.bright, italic = true },
    Constant = { fg = M.colors.white.dim },
    CurSearch = { link = "IncSearch" },
    Cursor = { bg = M.colors.white.dim, fg = M.colors.black.dim },
    CursorColumn = { link = "CursorLine" },
    CursorIM = { link = "Cursor" },
    CursorLine = { bg = M.colors.gray.base },
    CursorLineFold = { link = "FoldColumn" },
    CursorLineNr = { bold = true, fg = M.colors.yellow.base },
    CursorLineSign = { link = "SignColumn" },
    Debug = { link = "Special" },
    Define = { link = "PreProc" },
    Delimiter = { link = "Special" },
    DiagnosticDeprecated = { sp = M.colors.black.dim6, strikethrough = true },
    DiagnosticError = { fg = M.colors.red.base },
    DiagnosticHint = { fg = M.colors.blue.bright },
    DiagnosticInfo = { fg = M.colors.blue.base },
    DiagnosticOk = { fg = M.colors.green.base },
    DiagnosticUnderlineError = { fg = M.colors.red.base, sp = M.colors.gray.base, underline = true },
    DiagnosticUnderlineHint = { fg = M.colors.blue.base, sp = M.colors.blue.bright, underline = true },
    DiagnosticUnderlineInfo = { fg = M.colors.green.base, sp = M.colors.blue.base, underline = true },
    DiagnosticUnderlineOk = { sp = M.colors.green.base, undercurl = true },
    DiagnosticUnderlineWarn = { fg = M.colors.yellow.base, sp = M.colors.yellow.base, underline = true },
    DiagnosticUnnecessary = { link = "Comment" },
    DiagnosticWarn = { fg = M.colors.yellow.base },
    DiffAdd = { bg = M.colors.green.base },
    DiffChange = { bg = M.colors.yellow.base },
    DiffDelete = { bg = M.colors.red.base },
    DiffText = { bg = M.colors.red.base },
    Directory = { fg = M.colors.white.bright },
    EndOfBuffer = { fg = M.colors.black.dim },
    Error = { fg = M.colors.red.base },
    ErrorMsg = { fg = M.colors.red.base },
    Exception = { link = "Keyword" },
    Float = { link = "Number" },
    FloatBorder = { fg = M.colors.gray.base },
    FloatFooter = { link = "FloatTitle" },
    FloatShadow = { bg = M.colors.gray.base, blend = 80 },
    FloatShadowThrough = { bg = M.colors.gray.base, blend = 100 },
    FloatTitle = { fg = M.colors.white.bright },
    FocusedSymbol = { link = "Search" },
    FoldColumn = { fg = M.colors.gray.base },
    Folded = { bg = M.colors.black.dim, fg = M.colors.gray.base },
    Function = { fg = M.colors.white.bright, italic = true },
    Identifier = { fg = M.colors.white.base },
    Ignore = { link = "Normal" },
    IncSearch = { bg = M.colors.blue.bright, fg = M.colors.black.dim },
    Include = { link = "PreProc" },
    Italic = { italic = true },
    Keyword = { fg = M.colors.blue.base, italic = true },
    Label = { link = "Conditional" },
    LineNr = { fg = M.colors.gray.base },
    LineNrAbove = { link = "LineNr" },
    LineNrBelow = { link = "LineNr" },
    LspCodeLens = { fg = M.colors.gray.bright },
    LspCodeLensSeparator = { fg = M.colors.gray.base },
    LspFloatWinBorder = { fg = M.colors.gray.base },
    LspFloatWinNormal = { bg = M.colors.black.base },
    LspInfoBorder = { default = true, link = "Label" },
    LspInlayHint = { fg = M.colors.gray.bright },
    LspReferenceRead = { bg = M.colors.gray.base },
    LspReferenceText = { bg = M.colors.gray.base },
    LspReferenceWrite = { bg = M.colors.gray.base },
    LspSignatureActiveParameter = { fg = M.colors.gray.base },
    LspTroubleCount = { bg = M.colors.gray.base, fg = M.colors.magenta.base },
    LspTroubleNormal = { bg = M.colors.black.base, fg = M.colors.gray.base },
    LspTroubleText = { fg = M.colors.white.base },
    Macro = { link = "PreProc" },
    MatchBackground = { link = "ColorColumn" },
    MatchParen = { bg = M.colors.gray.base, fg = M.colors.cyan.bright },
    MatchParenCur = { link = "MatchParen" },
    MatchWord = { link = "MatchParen" },
    ModeMsg = { bold = true, fg = M.colors.white.dim },
    ModesCopy = { bg = M.colors.yellow.base },
    ModesDelete = { bg = M.colors.red.base },
    ModesInsert = { bg = M.colors.cyan.base },
    ModesVisual = { bg = M.colors.magenta.base },
    MoreMsg = { bold = true, fg = M.colors.cyan.bright },
    MsgArea = {},
    MsgSeparator = { link = "StatusLine" },
    NagicIconsOperator = { link = "Operator" },
    NavicIconsArray = { bg = M.colors.gray.base, fg = M.colors.yellow.base },
    NavicIconsBoolean = { bg = M.colors.gray.base, fg = M.colors.orange.base },
    NavicIconsClass = { bg = M.colors.gray.base, fg = M.colors.yellow.base },
    NavicIconsConstant = { bg = M.colors.gray.base, fg = M.colors.orange.base },
    NavicIconsConstructor = { bg = M.colors.gray.base, fg = M.colors.yellow.base },
    NavicIconsEnum = { bg = M.colors.gray.base, fg = M.colors.yellow.base },
    NavicIconsEnumMember = { bg = M.colors.gray.base, fg = M.colors.cyan.base },
    NavicIconsEvent = { bg = M.colors.gray.base, fg = M.colors.magenta.base },
    NavicIconsField = { bg = M.colors.gray.base, fg = M.colors.blue.base },
    NavicIconsFile = { bg = M.colors.gray.base, fg = M.colors.blue.base },
    NavicIconsFunction = { bg = M.colors.gray.base, fg = M.colors.magenta.base },
    NavicIconsInterface = { bg = M.colors.gray.base, fg = M.colors.yellow.base },
    NavicIconsKey = { bg = M.colors.gray.base, fg = M.colors.magenta.base },
    NavicIconsMethod = { bg = M.colors.gray.base, fg = M.colors.magenta.base },
    NavicIconsModule = { bg = M.colors.gray.base, fg = M.colors.blue.base },
    NavicIconsNamespace = { bg = M.colors.gray.base, fg = M.colors.yellow.base },
    NavicIconsNull = { bg = M.colors.gray.base, fg = M.colors.red.base },
    NavicIconsNumber = { bg = M.colors.gray.base, fg = M.colors.orange.base },
    NavicIconsObject = { bg = M.colors.gray.base, fg = M.colors.orange.base },
    NavicIconsOperator = { bg = M.colors.gray.base, fg = M.colors.magenta.base },
    NavicIconsPackage = { bg = M.colors.gray.base, fg = M.colors.orange.base },
    NavicIconsProperty = { bg = M.colors.gray.base, fg = M.colors.blue.base },
    NavicIconsString = { bg = M.colors.gray.base, fg = M.colors.green.base },
    NavicIconsStruct = { bg = M.colors.gray.base, fg = M.colors.yellow.base },
    NavicIconsTypeParameter = { bg = M.colors.gray.base, fg = M.colors.yellow.base },
    NavicIconsVariable = { bg = M.colors.gray.base, fg = M.colors.blue.base },
    NavicSeparator = { bg = M.colors.gray.base, fg = M.colors.cyan.base },
    NavicText = { bg = M.colors.gray.base, fg = M.colors.white.base },
    NeotestAdapterName = { bold = true, fg = M.colors.magenta.base },
    NeotestDir = { fg = M.colors.cyan.base },
    NeotestExpandMarker = { link = "Conceal" },
    NeotestFailed = { fg = M.colors.red.base },
    NeotestFile = { fg = M.colors.blue.base },
    NeotestFocused = { underline = true },
    NeotestIndent = { link = "Conceal" },
    NeotestMarked = { bold = true, fg = M.colors.white.dim },
    NeotestNamespace = { fg = M.colors.cyan.base },
    NeotestPassed = { fg = M.colors.green.base },
    NeotestRunning = { fg = M.colors.orange.base },
    NeotestSkipped = { fg = M.colors.yellow.base },
    NeotestTest = { link = "Normal" },
    NoiceCmdline = { default = true, link = "MsgArea" },
    NoiceCmdlineIcon = { link = "DiagnosticInfo" },
    NoiceCmdlineIconCalculator = { default = true, link = "NoiceCmdlineIcon" },
    NoiceCmdlineIconCmdline = { default = true, link = "NoiceCmdlineIcon" },
    NoiceCmdlineIconFilter = { default = true, link = "NoiceCmdlineIcon" },
    NoiceCmdlineIconGit = { default = true, link = "NoiceCmdlineIcon" },
    NoiceCmdlineIconHelp = { default = true, link = "NoiceCmdlineIcon" },
    NoiceCmdlineIconIncRename = { default = true, link = "NoiceCmdlineIcon" },
    NoiceCmdlineIconInput = { default = true, link = "NoiceCmdlineIcon" },
    NoiceCmdlineIconLua = { default = true, link = "NoiceCmdlineIcon" },
    NoiceCmdlineIconRead = { default = true, link = "NoiceCmdlineIcon" },
    NoiceCmdlineIconSearch = { link = "DiagnosticWarn" },
    NoiceCmdlineIconSession = { default = true, link = "NoiceCmdlineIcon" },
    NoiceCmdlineIconSubstitute = { default = true, link = "NoiceCmdlineIcon" },
    NoiceCmdlinePopup = { default = true, link = "Normal" },
    NoiceCmdlinePopupBorder = { link = "DiagnosticInfo" },
    NoiceCmdlinePopupBorderCalculator = { default = true, link = "NoiceCmdlinePopupBorder" },
    NoiceCmdlinePopupBorderCmdline = { default = true, link = "NoiceCmdlinePopupBorder" },
    NoiceCmdlinePopupBorderFilter = { default = true, link = "NoiceCmdlinePopupBorder" },
    NoiceCmdlinePopupBorderGit = { default = true, link = "NoiceCmdlinePopupBorder" },
    NoiceCmdlinePopupBorderHelp = { default = true, link = "NoiceCmdlinePopupBorder" },
    NoiceCmdlinePopupBorderIncRename = { default = true, link = "NoiceCmdlinePopupBorder" },
    NoiceCmdlinePopupBorderInput = { default = true, link = "NoiceCmdlinePopupBorder" },
    NoiceCmdlinePopupBorderLua = { default = true, link = "NoiceCmdlinePopupBorder" },
    NoiceCmdlinePopupBorderRead = { default = true, link = "NoiceCmdlinePopupBorder" },
    NoiceCmdlinePopupBorderSearch = { link = "DiagnosticWarn" },
    NoiceCmdlinePopupBorderSession = { default = true, link = "NoiceCmdlinePopupBorder" },
    NoiceCmdlinePopupBorderSubstitute = { default = true, link = "NoiceCmdlinePopupBorder" },
    NoiceCmdlinePopupTitle = { link = "DiagnosticInfo" },
    NoiceCmdlinePrompt = { default = true, link = "Title" },
    NoiceCompletionItemKindClass = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindColor = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindConstant = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindConstructor = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindDefault = { default = true, link = "Special" },
    NoiceCompletionItemKindEnum = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindEnumMember = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindField = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindFile = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindFolder = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindFunction = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindInterface = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindKeyword = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindMethod = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindModule = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindProperty = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindSnippet = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindStruct = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindText = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindUnit = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindValue = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceCompletionItemKindVariable = { default = true, link = "NoiceCompletionItemKindDefault" },
    NoiceConfirm = { default = true, link = "Normal" },
    NoiceConfirmBorder = { link = "DiagnosticInfo" },
    NoiceCursor = { default = true, link = "Cursor" },
    NoiceFormatConfirm = { default = true, link = "CursorLine" },
    NoiceFormatConfirmDefault = { default = true, link = "Visual" },
    NoiceFormatDate = { default = true, link = "Special" },
    NoiceFormatEvent = { default = true, link = "NonText" },
    NoiceFormatKind = { default = true, link = "NonText" },
    NoiceFormatLevelDebug = { default = true, link = "NonText" },
    NoiceFormatLevelError = { fg = M.colors.red.base },
    NoiceFormatLevelInfo = { fg = M.colors.blue.base },
    NoiceFormatLevelOff = { default = true, link = "NonText" },
    NoiceFormatLevelTrace = { default = true, link = "NonText" },
    NoiceFormatLevelWarn = { fg = M.colors.yellow.base },
    NoiceFormatProgressDone = { bg = M.colors.black.dim, fg = M.colors.white.bright },
    NoiceFormatProgressTodo = { bg = M.colors.black.dim, fg = M.colors.white.bright },
    NoiceFormatTitle = { default = true, link = "Title" },
    NoiceHiddenCursor = { blend = 100, nocombine = true },
    NoiceLspProgressClient = { fg = M.colors.blue.base },
    NoiceLspProgressSpinner = { fg = M.colors.cyan.bright },
    NoiceLspProgressTitle = { fg = M.colors.white.bright },
    NoiceMini = { default = true, link = "MsgArea" },
    NoicePopup = { default = true, link = "NormalFloat" },
    NoicePopupBorder = { default = true, link = "FloatBorder" },
    NoicePopupmenu = { default = true, link = "Pmenu" },
    NoicePopupmenuBorder = { default = true, link = "FloatBorder" },
    NoicePopupmenuMatch = { default = true, link = "Special" },
    NoicePopupmenuSelected = { default = true, link = "PmenuSel" },
    NoiceScrollbar = { default = true, link = "PmenuSbar" },
    NoiceScrollbarThumb = { default = true, link = "PmenuThumb" },
    NoiceSplit = { default = true, link = "NormalFloat" },
    NoiceSplitBorder = { default = true, link = "FloatBorder" },
    NoiceVirtualText = { fg = M.colors.blue.base },
    NonText = { fg = M.colors.white.base },
    Normal = { bg = M.colors.black.dim, fg = M.colors.white.dim },
    NormalFloat = { bg = M.colors.black.dim, fg = M.colors.white.dim },
    NormalNC = { bg = M.colors.black.dim, fg = M.colors.white.dim },
    NotifyBackground = { link = "NormalFloat" },
    NotifyDEBUGBody = { link = "Normal" },
    NotifyDEBUGBorder = { fg = M.colors.white.base },
    NotifyDEBUGIcon = { link = "NotifyDEBUGTitle" },
    NotifyDEBUGTitle = { fg = M.colors.blue.bright },
    NotifyERRORBody = { link = "Normal" },
    NotifyERRORBorder = { fg = M.colors.red.base },
    NotifyERRORIcon = { link = "NotifyERRORTitle" },
    NotifyERRORTitle = { fg = M.colors.red.base },
    NotifyINFOBody = { link = "Normal" },
    NotifyINFOBorder = { fg = M.colors.gray.base },
    NotifyINFOIcon = { link = "NotifyINFOTitle" },
    NotifyINFOTitle = { fg = M.colors.blue.base },
    NotifyLogTime = { link = "Comment" },
    NotifyLogTitle = { link = "Special" },
    NotifyTRACEBody = { link = "Normal" },
    NotifyTRACEBorder = { fg = M.colors.black.bright },
    NotifyTRACEIcon = { link = "NotifyTRACETitle" },
    NotifyTRACETitle = { fg = M.colors.gray.bright },
    NotifyWARNBody = { link = "Normal" },
    NotifyWARNBorder = { fg = M.colors.yellow.base },
    NotifyWARNIcon = { link = "NotifyWARNTitle" },
    NotifyWARNTitle = { fg = M.colors.yellow.base },
    Number = { fg = M.colors.magenta.base },
    Operator = { fg = M.colors.blue.base },
    Pmenu = { bg = M.colors.gray.base, fg = M.colors.white.dim },
    PmenuExtra = { link = "Pmenu" },
    PmenuExtraSel = { link = "PmenuSel" },
    PmenuKind = { link = "Pmenu" },
    PmenuKindSel = { link = "PmenuSel" },
    PmenuSbar = { link = "PmenuSel" },
    PmenuSel = { bg = M.colors.gray.bright },
    PmenuThumb = { bg = M.colors.gray.base },
    PreCondit = { link = "PreProc" },
    PreProc = { fg = M.colors.blue.bright },
    Question = { link = "MoreMsg" },
    QuickFixLine = { link = "CursorLine" },
    Removed = { fg = M.colors.red.base },
    Repeat = { link = "Conditional" },
    Search = { bg = M.colors.gray.base, fg = M.colors.white.dim },
    SignColumn = { fg = M.colors.gray.base },
    SignColumnSB = { link = "SignColumn" },
    SnippetTabstop = { link = "Visual" },
    Special = { fg = M.colors.white.bright },
    SpecialChar = { link = "Special" },
    SpecialComment = { link = "Special" },
    SpecialKey = { link = "NonText" },
    SpellBad = { sp = M.colors.red.base, undercurl = true },
    SpellCap = { sp = M.colors.yellow.base, undercurl = true },
    SpellLocal = { sp = M.colors.blue.base, undercurl = true },
    SpellRare = { sp = M.colors.blue.base, undercurl = true },
    Statement = { fg = M.colors.blue.base, italic = true },
    StatusLine = { bg = M.colors.gray.base, fg = M.colors.cyan.bright },
    StatusLineNC = { bg = M.colors.black.base, fg = M.colors.gray.base },
    StorageClass = { link = "Type" },
    String = { fg = M.colors.green.base },
    Structure = { link = "Type" },
    Substitute = { bg = M.colors.red.base, fg = M.colors.black.dim },
    TabLine = { bg = M.colors.black.dark, fg = M.colors.white.base },
    TabLineFill = { bg = M.colors.black.dark },
    TabLineSel = { bg = M.colors.gray.base, fg = M.colors.white.base },
    Tag = { link = "Special" },
    TermCursor = { reverse = true },
    TermCursorNC = {},
    Terminal = { bg = M.colors.black.dim, fg = M.colors.white.dim },
    Title = { bold = true, fg = M.colors.white.bright },
    Todo = { bg = M.colors.blue.base, fg = M.colors.black.dim },
    Type = { fg = M.colors.cyan.base, italic = true },
    Typedef = { link = "Type" },
    Underlined = { underline = true },
    UnderlinedTitle = { bold = true, underline = true },
    VertSplit = { link = "WinSeparator" },
    Visual = { bg = M.colors.gray.base },
    VisualNOS = { link = "Visual" },
    WarningMsg = { fg = M.colors.yellow.base },
    WhichKey = { link = "Identifier" },
    WhichKeyBorder = { default = true, link = "FloatBorder" },
    WhichKeyDesc = { link = "Keyword" },
    WhichKeyFloat = { link = "NormalFloat" },
    WhichKeyGroup = { link = "Function" },
    WhichKeySeparator = { link = "Comment" },
    WhichKeyValue = { link = "Comment" },
    Whitespace = { fg = M.colors.gray.base },
    WildMenu = { link = "Pmenu" },
    WinBar = { link = "StatusLine" },
    WinBarNC = { link = "StatusLineNC" },
    WinSeparator = { fg = M.colors.black.base },
    ["@attribute"] = { fg = M.colors.blue.base },
    ["@attribute.builtin"] = { link = "Special" },
    ["@boolean"] = { link = "Boolean" },
    ["@character"] = { link = "Character" },
    ["@character.special"] = { link = "SpecialChar" },
    ["@comment"] = { link = "Comment" },
    ["@comment.error"] = { fg = M.colors.red.base },
    ["@comment.note"] = { fg = M.colors.blue.base },
    ["@comment.todo"] = { fg = M.colors.orange.base },
    ["@comment.warning"] = { fg = M.colors.yellow.base },
    ["@conditional"] = { link = "Conditional" },
    ["@constant"] = { link = "Constant" },
    ["@constant.builtin"] = { fg = M.colors.blue.base, italic = true },
    ["@constant.macro"] = { link = "Macro" },
    ["@constructor"] = { fg = M.colors.white.base, italic = true },
    ["@constructor.lua"] = { fg = M.colors.white.base },
    ["@diff.delta"] = { fg = M.colors.yellow.base },
    ["@diff.minus"] = { fg = M.colors.red.base },
    ["@diff.plus"] = { fg = M.colors.green.base },
    ["@exception"] = { link = "Exception" },
    ["@field"] = { fg = M.colors.blue.base },
    ["@field.rust"] = { fg = M.colors.white.base },
    ["@float"] = { link = "Float" },
    ["@function"] = { link = "Function" },
    ["@function.builtin"] = { fg = M.colors.blue.base, italic = true },
    ["@function.macro"] = { fg = M.colors.blue.base, italic = true },
    ["@include"] = { link = "Include" },
    ["@keyword"] = { link = "Keyword" },
    ["@keyword.conditional"] = { link = "Conditional" },
    ["@keyword.conditional.ternary"] = { link = "Conditional" },
    ["@keyword.exception"] = { fg = M.colors.blue.base },
    ["@keyword.function"] = { fg = M.colors.blue.base, italic = true },
    ["@keyword.import"] = { link = "Include" },
    ["@keyword.operator"] = { fg = M.colors.blue.base },
    ["@keyword.repeat"] = { fg = M.colors.blue.base, italic = true },
    ["@keyword.return"] = { fg = M.colors.blue.base, italic = true },
    ["@keyword.storage"] = { link = "StorageClass" },
    ["@label"] = { link = "Label" },
    ["@label.json"] = { fg = M.colors.white.bright },
    ["@lsp.mod.deprecated"] = { link = "DiagnosticDeprecated" },
    ["@lsp.type.boolean"] = { link = "@boolean" },
    ["@lsp.type.builtinType"] = { link = "@type.builtin" },
    ["@lsp.type.class"] = { link = "@type" },
    ["@lsp.type.comment"] = { link = "@comment" },
    ["@lsp.type.comment.lua"] = {},
    ["@lsp.type.decorator"] = { link = "@attribute" },
    ["@lsp.type.enum"] = { link = "@type" },
    ["@lsp.type.enumMember"] = { link = "@constant" },
    ["@lsp.type.escapeSequence"] = { link = "@string.escape" },
    ["@lsp.type.event"] = { link = "@type" },
    ["@lsp.type.formatSpecifier"] = { link = "@punctuation.special" },
    ["@lsp.type.function"] = { link = "@function" },
    ["@lsp.type.interface"] = { fg = M.colors.red.base },
    ["@lsp.type.interface.rust"] = {},
    ["@lsp.type.keyword"] = { link = "@keyword" },
    ["@lsp.type.macro"] = { link = "@constant.macro" },
    ["@lsp.type.method"] = {},
    ["@lsp.type.modifier"] = {},
    ["@lsp.type.namespace"] = { link = "@module" },
    ["@lsp.type.number"] = { link = "@number" },
    ["@lsp.type.operator"] = { link = "@operator" },
    ["@lsp.type.parameter"] = { link = "@parameter" },
    ["@lsp.type.property"] = { link = "@property" },
    ["@lsp.type.regexp"] = { link = "@string.regexp" },
    ["@lsp.type.selfKeyword"] = { link = "@variable.builtin" },
    ["@lsp.type.string"] = { link = "@string" },
    ["@lsp.type.struct"] = { link = "@type" },
    ["@lsp.type.type"] = { link = "@type" },
    ["@lsp.type.typeAlias"] = {},
    ["@lsp.type.typeParameter"] = { link = "@parameter" },
    ["@lsp.type.unresolvedReference"] = {},
    ["@lsp.type.variable"] = {},
    ["@lsp.typemod.class.defaultLibrary"] = { link = "@type.builtin" },
    ["@lsp.typemod.enum.defaultLibrary"] = { link = "@type.builtin" },
    ["@lsp.typemod.enumMember.defaultLibrary"] = { link = "@constant.builtin" },
    ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
    ["@lsp.typemod.keyword.async"] = {},
    ["@lsp.typemod.macro.defaultLibrary"] = { link = "@function.builtin" },
    ["@lsp.typemod.method.defaultLibrary"] = { link = "@function.builtin" },
    ["@lsp.typemod.operator.injected"] = { link = "@operator" },
    ["@lsp.typemod.string.injected"] = { link = "@string" },
    ["@lsp.typemod.type.defaultLibrary"] = { link = "@type.builtin" },
    ["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
    ["@lsp.typemod.variable.injected"] = { link = "@variable" },
    ["@markup"] = { fg = M.colors.white.dim },
    ["@markup.emphasis"] = { fg = M.colors.white.dim, italic = true },
    ["@markup.heading"] = { link = "Title" },
    ["@markup.italic"] = {},
    ["@markup.link"] = { bold = true, fg = M.colors.blue.base },
    ["@markup.link.label"] = { link = "Special" },
    ["@markup.link.url"] = { link = "@string.special.url" },
    ["@markup.list"] = { fg = M.colors.blue.base },
    ["@markup.list.checked"] = { fg = M.colors.green.base },
    ["@markup.list.unchecked"] = { fg = M.colors.yellow.base },
    ["@markup.math"] = { fg = M.colors.white.bright },
    ["@markup.note"] = { fg = M.colors.orange.base },
    ["@markup.quote"] = { fg = M.colors.white.base },
    ["@markup.raw"] = { fg = M.colors.white.base, italic = true },
    ["@markup.raw.block"] = { fg = M.colors.magenta.base },
    ["@markup.strikethrough"] = { fg = M.colors.white.dim, strikethrough = true },
    ["@markup.strong"] = { bold = true, fg = M.colors.white.dim },
    ["@markup.underline"] = {},
    ["@module"] = { fg = M.colors.cyan.base, italic = true },
    ["@module.builtin"] = { link = "Special" },
    ["@namespace"] = { fg = M.colors.cyan.base },
    ["@number"] = { link = "Number" },
    ["@number.float"] = { link = "Float" },
    ["@operator"] = { link = "Operator" },
    ["@parameter"] = { fg = M.colors.yellow.base },
    ["@property"] = { fg = M.colors.blue.base },
    ["@punctuation"] = { link = "Delimiter" },
    ["@punctuation.bracket"] = { fg = M.colors.blue.base },
    ["@punctuation.delimiter"] = { fg = M.colors.blue.base },
    ["@punctuation.special"] = { fg = M.colors.cyan.base },
    ["@repeat"] = { link = "Repeat" },
    ["@storageclass"] = { link = "StorageClass" },
    ["@string"] = { link = "String" },
    ["@string.escape"] = { bold = true, fg = M.colors.gray.bright },
    ["@string.regex"] = { fg = M.colors.gray.bright },
    ["@string.regexp"] = { fg = M.colors.gray.bright },
    ["@string.special"] = { link = "Special" },
    ["@string.special.url"] = { fg = M.colors.white.dim },
    ["@tag"] = { fg = M.colors.blue.base },
    ["@tag.attribute"] = { fg = M.colors.white.bright, italic = true },
    ["@tag.builtin"] = { link = "Special" },
    ["@tag.delimiter"] = { fg = M.colors.cyan.base },
    ["@text"] = { fg = M.colors.white.dim },
    ["@text.danger"] = { bg = M.colors.red.base, fg = M.colors.black.dim },
    ["@text.diff.add"] = { fg = M.colors.green.base },
    ["@text.diff.delete"] = { fg = M.colors.red.base },
    ["@text.emphasis"] = {},
    ["@text.literal"] = { fg = M.colors.white.base, italic = true },
    ["@text.math"] = { fg = M.colors.white.bright },
    ["@text.note"] = { bg = M.colors.blue.base, fg = M.colors.black.dim },
    ["@text.reference"] = { bold = true, fg = M.colors.blue.base },
    ["@text.strike"] = { fg = M.colors.white.dim, strikethrough = true },
    ["@text.strong"] = { bold = true, fg = M.colors.red.base },
    ["@text.title"] = { link = "Title" },
    ["@text.todo"] = { bg = M.colors.blue.bright, fg = M.colors.black.dim },
    ["@text.todo.checked"] = { fg = M.colors.green.base },
    ["@text.todo.unchecked"] = { fg = M.colors.yellow.base },
    ["@text.underline"] = {},
    ["@text.warning"] = { bg = M.colors.yellow.base, fg = M.colors.black.dim },
    ["@type"] = { link = "Type" },
    ["@type.builtin"] = { fg = M.colors.cyan.base, italic = true },
    ["@variable"] = { fg = M.colors.white.dim },
    ["@variable.builtin"] = { fg = M.colors.blue.base },
    ["@variable.member"] = { fg = M.colors.blue.base },
    ["@variable.parameter"] = { fg = M.colors.yellow.base, italic = true },
    ["@variable.parameter.builtin"] = { link = "Special" },
}

-- Keymap helpers.
M.cmd = function(cmd)
    return "<cmd>" .. cmd .. "<CR>"
end

M.cmd_alt = function(cmd)
    return ":" .. cmd .. "<CR>"
end

M.lua = function(cmd)
    return "<cmd>lua " .. cmd .. "<CR>"
end

return M
