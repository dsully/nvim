--
-- Nord palette : https://www.nordtheme.com/docs/colors-and-palettes
local colors = {
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

    none = "NONE",
}

-- Aliases
colors.fg = colors.white.base
colors.bg = colors.black.dim

colors.night = {
    c0 = colors.black.dim,
    c1 = colors.black.base,
    c2 = colors.black.bright,
    c3 = colors.gray.base,
}

colors.snow = {
    c0 = colors.white.dim,
    c1 = colors.white.base,
    c2 = colors.white.bright,
}

colors.frost = {
    blue = colors.blue.bright,
    light_blue = colors.blue.base,
    sea = colors.cyan.base,
    turquoise = colors.cyan.bright,
}

colors.aurora = {
    green = colors.green.base,
    orange = colors.orange.base,
    purple = colors.magenta.base,
    red = colors.red.base,
    yellow = colors.yellow.base,
}

colors.blend = {
    red = "#3c3944",
    yellow = "#414348",
    green = "#3a4248",
    turquoise = "#37424e",
    blue = "#384356",
    bluec1 = "#3c4b60",
    comment = "#5c6881",
}

colors.special = {
    sea = "#8ebdbc",
    light_blue = "#7aa1be",
}

vim.g.terminal_color_0 = colors.black.dark
vim.g.terminal_color_8 = colors.black.base
vim.g.terminal_color_1 = colors.red.base
vim.g.terminal_color_9 = colors.red.bright
vim.g.terminal_color_2 = colors.green.base
vim.g.terminal_color_10 = colors.green.bright
vim.g.terminal_color_3 = colors.yellow.base
vim.g.terminal_color_11 = colors.yellow.bright
vim.g.terminal_color_4 = colors.blue.bright
vim.g.terminal_color_12 = colors.cyan.bright
vim.g.terminal_color_5 = colors.magenta.base
vim.g.terminal_color_13 = colors.magenta.bright
vim.g.terminal_color_6 = colors.cyan.base
vim.g.terminal_color_14 = colors.cyan.bright
vim.g.terminal_color_7 = colors.white.base
vim.g.terminal_color_15 = colors.white.dim

local M = {
    colors = colors,
}

---@alias HighlightName string
---@alias Highlight table<string, vim.api.keyset.highlight>>

---@type table<HighlightName, Highlight>
M.ui = {
    core = {
        Added = { link = "DiffAdd" },
        Bold = { bold = true },
        Changed = { link = "DiffChange" },
        ColorColumn = { bg = colors.black.dim },
        Conceal = { fg = colors.black.bright },
        CurSearch = { bg = colors.blue.bright, fg = colors.black.dim },
        Cursor = { bg = colors.white.dim, fg = colors.black.dim },
        CursorColumn = { bg = colors.gray.base },
        CursorLine = { bg = "None" },
        CursorLineNr = { bold = true, fg = colors.yellow.base },
        DiffAdd = {
            fg = colors.green.base,
            bg = colors.black.dim,
            -- bg = colors.blend.green,
        },
        DiffChange = {
            fg = colors.yellow.base,
            bg = colors.black.dim,
            -- bg = colors.blend.yellow,
        },
        DiffDelete = {
            fg = colors.red.base,
            bg = colors.black.dim,
            -- bg = colors.blend.red,
        },
        DiffText = {
            fg = colors.blue.base,
            bg = colors.black.dim,
            -- bg = colors.bg,
        },
        Directory = { fg = colors.white.bright },
        EndOfBuffer = { fg = colors.black.dim },
        ErrorMsg = { fg = colors.red.base },
        FloatBorder = { fg = colors.gray.base },
        FloatShadow = { bg = colors.gray.base, blend = 80 },
        FloatShadowThrough = { bg = colors.gray.base, blend = 100 },
        FloatTitle = { fg = colors.white.bright },
        FoldColumn = { fg = colors.gray.base },
        Folded = { bg = colors.black.dim, fg = colors.gray.base },
        LineNr = { fg = colors.gray.base },
        ModeMsg = { bold = true, fg = colors.white.dim },
        ModesCopy = { bg = colors.yellow.base },
        ModesDelete = { bg = colors.red.base },
        ModesInsert = { bg = colors.cyan.base },
        ModesVisual = { bg = colors.magenta.base },
        MoreMsg = { bold = true, fg = colors.cyan.bright },
        MsgArea = {},
        NonText = { fg = colors.white.base },
        Normal = { bg = colors.black.dim, fg = colors.white.dim },
        NormalFloat = { bg = colors.black.dim, fg = colors.white.dim },
        NormalNC = { bg = colors.black.dim, fg = colors.white.dim },
        Pmenu = { bg = colors.gray.base, fg = colors.white.dim },
        PmenuSbar = { link = "PmenuSel" },
        -- https://www.reddit.com/r/neovim/comments/1f439w8/psa_for_color_scheme_authors_you_might_want_to/
        -- Matched text in normal item
        PmenuSel = { fg = colors.blue.base, bg = colors.black.base, blend = 0, bold = true, reverse = true, cterm = { reverse = true } },
        -- Matched text in selected item
        PmenuMatchSel = { fg = colors.blue.base, bg = colors.gray.base, bold = true, reverse = true, cterm = { reverse = true } },
        PmenuThumb = { bg = colors.gray.base },
        Question = { link = "MoreMsg" },
        QuickFixLine = { link = "CursorLine" },
        Removed = { link = "DiffDelete" },
        Search = { bg = colors.gray.base, fg = colors.white.dim },
        SignColumn = { fg = colors.gray.base },
        SpecialKey = { link = "NonText" },
        StatusLine = { bg = colors.gray.base, fg = colors.cyan.bright },
        StatusLineNC = { bg = colors.black.base, fg = colors.gray.base },
        Substitute = { bg = colors.red.base, fg = colors.black.dim },
        TabLine = { bg = colors.black.dark, fg = colors.white.base },
        TabLineFill = { bg = colors.black.dark },
        TabLineSel = { bg = colors.gray.base, fg = colors.white.base },
        TermCursor = { reverse = true },
        TermCursorNC = {},
        Terminal = { bg = colors.black.dim, fg = colors.white.dim },
        Title = { bold = true, fg = colors.white.bright },
        UnderlinedTitle = { bold = true, underline = true },
        Visual = { bg = colors.gray.base },
        Whitespace = { fg = colors.gray.base },
        WildMenu = { link = "Pmenu" },
        WinBar = { link = "StatusLine" },
        WinBarNC = { link = "StatusLineNC" },
        WinSeparator = { fg = colors.black.base },
    },

    syntax = {
        Boolean = { link = "Number" },
        Character = { link = "String" },
        Comment = { fg = colors.gray.bright },
        Conditional = { fg = colors.blue.bright, italic = true },
        Constant = { fg = colors.white.dim },
        Debug = { link = "Special" },
        Define = { link = "PreProc" },
        Delimiter = { link = "Special" },
        Directory = { fg = colors.white.bright },
        Error = { fg = colors.red.base },
        Exception = { link = "Keyword" },
        Float = { link = "Number" },
        Function = { fg = colors.white.bright, italic = true },
        Identifier = { fg = colors.white.base },
        Ignore = { link = "Normal" },
        Include = { link = "PreProc" },
        Keyword = { fg = colors.blue.base, italic = true },
        Label = { link = "Conditional" },
        Macro = { link = "PreProc" },
        Number = { fg = colors.magenta.base },
        Operator = { fg = colors.blue.base },
        PreCondit = { link = "PreProc" },
        PreProc = { fg = colors.blue.bright },
        Repeat = { link = "Conditional" },
        Special = { fg = colors.white.bright },
        SpecialChar = { link = "Special" },
        SpecialComment = { link = "Special" },
        Statement = { fg = colors.blue.base, italic = true },
        StorageClass = { link = "Type" },
        String = { fg = colors.green.base },
        Structure = { link = "Type" },
        Tag = { link = "Special" },
        Todo = { bg = colors.blue.base, fg = colors.black.dim },
        Type = { fg = colors.cyan.base, italic = true },
        Typedef = { link = "Type" },
        Underlined = { underline = true },
        WinSeparator = { fg = colors.black.base },
    },

    treesitter = {
        ["@attribute"] = { fg = colors.blue.base }, -- attribute annotations (e.g. Python decorators, Rust lifetimes)
        ["@attribute.builtin"] = { link = "Special" }, -- builtin annotations (e.g. `@property` in Python)
        ["@boolean"] = { link = "Boolean" }, -- boolean literals
        ["@character"] = { link = "Character" }, -- character literals
        ["@character.special"] = { link = "SpecialChar" }, -- special characters (e.g. wildcards)
        ["@comment"] = { link = "Comment" }, -- line and block comments
        ["@comment.error"] = { fg = colors.red.base }, -- error-type comments (e.g. `ERROR`, `FIXME`, `DEPRECATED`)
        ["@comment.note"] = { fg = colors.blue.base }, -- note-type comments (e.g. `NOTE`, `INFO`, `XXX`)
        ["@comment.todo"] = { fg = colors.orange.base }, -- todo-type comments (e.g. `TODO`, `WIP`)
        ["@comment.warning"] = { fg = colors.yellow.base }, -- warning-type comments (e.g. `WARNING`, `FIX`, `HACK`)
        ["@conditional"] = { link = "Conditional" },
        ["@constant"] = { link = "Constant" }, -- constant identifiers
        ["@constant.builtin"] = { fg = colors.blue.base, italic = true }, -- built-in constant values
        ["@constant.git_rebase"] = { fg = colors.cyan.base },
        ["@constant.macro"] = { link = "Macro" }, -- constants defined by the preprocessor
        ["@constructor"] = { fg = colors.white.base, italic = true }, -- constructor calls and definitions
        ["@diff.delta"] = { link = "DiffChange" }, -- changed text (for diff files)
        ["@diff.minus"] = { link = "DiffDelete" }, -- deleted text (for diff files)
        ["@diff.plus"] = { link = "DiffAdd" }, -- added text (for diff files)
        ["@exception"] = { link = "Exception" }, -- keywords related to exceptions (e.g. `throw`, `catch`)
        ["@float"] = { link = "Float" }, -- floating-point number literals
        ["@function"] = { link = "Function" }, -- function definitions
        ["@function.builtin"] = { fg = colors.blue.base, italic = true }, -- built-in functions
        ["@function.call"] = { fg = colors.blue.base, italic = true }, -- function calls
        ["@function.macro"] = { fg = colors.blue.base, italic = true }, -- preprocessor macros
        ["@function.method"] = { fg = colors.white.base }, -- method definitions
        ["@function.method.call"] = { fg = colors.white.bright }, -- method calls
        ["@include"] = { link = "Include" }, -- keywords for including or exporting modules (e.g. `import`, `from` in Python)
        ["@keyword"] = { link = "Keyword" }, -- keywords not fitting into specific categories
        ["@keyword.conditional"] = { link = "Conditional" }, -- keywords related to conditionals (e.g. `if`, `else`)
        ["@keyword.conditional.ternary"] = { link = "Conditional" }, -- ternary operator (e.g. `?`, `:`)
        ["@keyword.exception"] = { fg = colors.blue.base }, -- keywords related to exceptions (e.g. `throw`, `catch`)
        ["@keyword.function"] = { fg = colors.blue.base, italic = true }, -- keywords that define a function (e.g. `func` in Go, `def` in Python)
        ["@keyword.import"] = { link = "Include" }, -- keywords for including or exporting modules (e.g. `import`, `from` in Python)
        ["@keyword.operator"] = { fg = colors.blue.base }, -- operators that are English words (e.g. `and`, `or`)
        ["@keyword.repeat"] = { fg = colors.blue.base, italic = true }, -- keywords related to loops (e.g. `for`, `while`)
        ["@keyword.return"] = { fg = colors.blue.base, italic = true }, -- keywords like `return` and `yield`
        ["@keyword.storage"] = { link = "StorageClass" }, -- keywords describing namespaces and composite types (e.g. `struct`, `enum`)
        ["@label"] = { link = "Label" }, -- `GOTO` and other labels (e.g. `label:` in C), including heredoc labels
        ["@module"] = { fg = colors.cyan.base, italic = true }, -- modules or namespaces
        ["@module.builtin"] = { link = "Special" }, -- built-in modules or namespaces
        ["@namespace"] = { fg = colors.cyan.base },
        ["@number"] = { link = "Number" }, -- numeric literals
        ["@number.float"] = { link = "Float" }, -- floating-point number literals
        ["@operator"] = { link = "Operator" }, -- symbolic operators (e.g. `+`, `*`)
        ["@property"] = { fg = colors.blue.base }, -- the key in key/value pairs
        ["@punctuation"] = { link = "Delimiter" },
        ["@punctuation.bracket"] = { fg = colors.blue.base }, -- brackets (e.g. `()`, `{}`, `[]`)
        ["@punctuation.delimiter"] = { fg = colors.blue.base }, -- delimiters (e.g. `;`, `.`, `,`)
        ["@punctuation.special"] = { fg = colors.cyan.base }, -- special symbols (e.g. `{}` in string interpolation)
        ["@repeat"] = { link = "Repeat" }, -- keywords related to loops (e.g. `for`, `while`)
        ["@storageclass"] = { link = "StorageClass" }, -- keywords describing namespaces and composite types (e.g. `struct`, `enum`)
        ["@string"] = { link = "String" }, -- string literals
        ["@string.escape"] = { bold = true, fg = colors.gray.bright }, -- escape sequences
        ["@string.regex"] = { fg = colors.gray.bright }, -- regular expressions
        ["@string.regexp"] = { fg = colors.gray.bright }, -- regular expressions
        ["@string.special"] = { link = "Special" }, -- other special strings (e.g. dates)
        ["@string.special.url"] = { fg = colors.white.dim }, -- URIs (e.g. hyperlinks)
        ["@tag"] = { fg = colors.blue.base }, -- XML-style tag names (e.g. in XML, HTML, etc.)
        ["@tag.attribute"] = { fg = colors.white.bright, italic = true }, -- XML-style tag attributes
        ["@tag.builtin"] = { link = "Special" }, -- builtin tag names (e.g. HTML5 tags)
        ["@tag.delimiter"] = { fg = colors.cyan.base }, -- XML-style tag delimiters
        ["@text"] = { fg = colors.white.dim },
        ["@text.danger"] = { bg = colors.red.base, fg = colors.black.dim },
        ["@text.diff.add"] = { fg = colors.green.base },
        ["@text.diff.delete"] = { fg = colors.red.base },
        ["@text.emphasis"] = {},
        ["@text.literal"] = { fg = colors.white.base, italic = true },
        ["@text.math"] = { fg = colors.white.bright },
        ["@text.note"] = { bg = colors.blue.base, fg = colors.black.dim },
        ["@text.reference"] = { bold = true, fg = colors.blue.base },
        ["@text.strike"] = { fg = colors.white.dim, strikethrough = true },
        ["@text.strong"] = { bold = true, fg = colors.red.base },
        ["@text.title"] = { link = "Title" },
        ["@text.todo"] = { bg = colors.blue.bright, fg = colors.black.dim },
        ["@text.todo.checked"] = { fg = colors.green.base },
        ["@text.todo.unchecked"] = { fg = colors.yellow.base },
        ["@text.underline"] = {},
        ["@text.warning"] = { bg = colors.yellow.base, fg = colors.black.dim },
        ["@type"] = { link = "Type" }, -- type or class definitions and annotations
        ["@type.builtin"] = { fg = colors.cyan.base, italic = true }, -- built-in types
        ["@type.qualifier"] = { fg = colors.cyan.base }, -- type qualifiers (e.g. `const`)
        ["@variable"] = { fg = colors.white.dim }, -- various variable names
        ["@variable.builtin"] = { fg = colors.blue.base }, -- built-in variable names (e.g. `this`, `self`)
        ["@variable.member"] = { fg = colors.blue.base }, -- object and struct fields
        ["@variable.parameter"] = { fg = colors.yellow.base, italic = true }, -- parameters of a function
        ["@variable.parameter.builtin"] = { link = "Special" }, -- special parameters (e.g. `_`, `it`)
    },

    diff = {
        Added = { link = "DiffAdd" },
        Changed = { link = "DiffChange" },
        DiffAdd = { fg = colors.green.base },
        DiffChange = { fg = colors.yellow.base },
        DiffDelete = { fg = colors.red.base },
        DiffText = { fg = colors.red.base },
        Removed = { link = "DiffDelete" },
        diffAdded = { link = "DiffAdd" },
        diffChanged = { link = "DiffChange" },
        diffFile = { fg = colors.cyan.bright, bg = colors.none },
        diffIndexLine = { link = "Comment" },
        diffLine = { fg = colors.yellow.base, bg = colors.none },
        diffRemoved = { link = "DiffDelete" },
    },

    diagnostics = {
        DiagnosticDeprecated = { sp = colors.black.dim6, strikethrough = true },
        DiagnosticError = { fg = colors.red.base },
        DiagnosticHint = { fg = colors.blue.bright },
        DiagnosticInfo = { fg = colors.blue.base },
        DiagnosticOk = { fg = colors.green.base },
        DiagnosticUnderlineError = { fg = colors.red.base, sp = colors.gray.base, underline = true },
        DiagnosticUnderlineHint = { fg = colors.blue.base, sp = colors.blue.bright, underline = true },
        DiagnosticUnderlineInfo = { fg = colors.green.base, sp = colors.blue.base, underline = true },
        DiagnosticUnderlineOk = { sp = colors.green.base, undercurl = true },
        DiagnosticUnderlineWarn = { fg = colors.yellow.base, sp = colors.yellow.base, underline = true },
        DiagnosticWarn = { fg = colors.yellow.base },
        ErrorMsg = { fg = colors.red.base },
        WarningMsg = { fg = colors.yellow.base },
    },

    lsp = {
        LspCodeLens = { fg = colors.gray.bright },
        LspCodeLensSeparator = { fg = colors.gray.base },
        LspInlayHint = { fg = colors.gray.bright },
        LspReferenceRead = { bg = colors.gray.base },
        LspReferenceText = { bg = colors.gray.base },
        LspReferenceWrite = { bg = colors.gray.base },
        LspSignatureActiveParameter = { fg = colors.gray.base },
    },

    semantic_tokens = {
        ["@lsp.type.boolean"] = { link = "@boolean" },
        ["@lsp.type.builtinType"] = { link = "@type.builtin" },
        ["@lsp.type.class"] = { link = "@class" },
        ["@lsp.type.comment"] = { link = "@comment" },
        ["@lsp.type.decorator"] = { link = "@constant.macro" },
        ["@lsp.type.deriveHelper"] = { link = "@attribute" },
        ["@lsp.type.enum"] = { link = "@constant" },
        ["@lsp.type.enumMember"] = { link = "@constant" },
        ["@lsp.type.escapeSequence"] = { link = "@string.escape" },
        ["@lsp.type.event"] = { link = "Identifier" },
        ["@lsp.type.formatSpecifier"] = { link = "@markup.list" },
        ["@lsp.type.function"] = { link = "@function" },
        ["@lsp.type.function.call"] = { link = "@function.call" },
        ["@lsp.type.generic"] = { link = "@variable" },
        ["@lsp.type.interface"] = { fg = colors.red.base, bold = true },
        ["@lsp.type.lifetime"] = { link = "@keyword.storage" },
        ["@lsp.type.method"] = { link = "@function.method" },
        ["@lsp.type.modifier"] = { link = "Identifier" },
        ["@lsp.type.namespace"] = { link = "@module" },
        ["@lsp.type.number"] = { link = "@number" },
        ["@lsp.type.operator"] = { link = "@operator" },
        ["@lsp.type.parameter"] = { link = "@variable.parameter" },
        ["@lsp.type.property"] = { link = "@property" },
        ["@lsp.type.regexp"] = { link = "@string.regexp" },
        ["@lsp.type.selfKeyword"] = { link = "@variable.builtin" },
        ["@lsp.type.selfTypeKeyword"] = { link = "@variable.builtin" },
        ["@lsp.type.string"] = { link = "@string" },
        ["@lsp.type.struct"] = { link = "@structure" },
        ["@lsp.type.type"] = { link = "@type" },
        ["@lsp.type.typeAlias"] = { link = "@type.definition" },
        ["@lsp.type.typeParameter"] = { link = "@lsp.type.class" },
        ["@lsp.type.unresolvedReference"] = { link = "DiagnosticUnderlineError" },
        ["@lsp.type.variable"] = {}, -- fallback to treesitter

        -- LSP Semantic Modifier Tokens
        ["@lsp.typemod.class.defaultLibrary"] = { link = "@type.builtin" },
        ["@lsp.typemod.enum.defaultLibrary"] = { link = "@type.builtin" },
        ["@lsp.typemod.enum.public"] = { link = "@type.builtin" },
        ["@lsp.typemod.enumMember.defaultLibrary"] = { link = "@constant.builtin" },
        ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
        ["@lsp.typemod.keyword.async"] = { link = "@keyword.coroutine" },
        ["@lsp.typemod.keyword.injected"] = { link = "@keyword" },
        ["@lsp.typemod.macro.defaultLibrary"] = { link = "@function.builtin" },
        ["@lsp.typemod.method.defaultLibrary"] = { link = "@function.builtin" },
        ["@lsp.typemod.operator.injected"] = { link = "@operator" },
        ["@lsp.typemod.string.injected"] = { link = "@string" },
        ["@lsp.typemod.struct.defaultLibrary"] = { link = "@type.builtin" },
        ["@lsp.typemod.type.defaultLibrary"] = { link = "@type.builtin" },
        ["@lsp.typemod.typeAlias.defaultLibrary"] = { link = "@type.builtin" },
        ["@lsp.typemod.variable.callable"] = { link = "@function" },
        ["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
        ["@lsp.typemod.variable.injected"] = { link = "@variable" },
        ["@lsp.typemod.variable.static"] = { link = "@constant" },
    },

    spelling = {
        SpellBad = { sp = colors.red.base, undercurl = true },
        SpellCap = { sp = colors.yellow.base, undercurl = true },
        SpellLocal = { sp = colors.blue.base, undercurl = true },
        SpellRare = { sp = colors.blue.base, undercurl = true },
    },
}

---@type table<string, table<string, vim.api.keyset.highlight>>
M.languages = {

    bash = {
        ["@constant.bash"] = { fg = colors.fg, bg = colors.none },
        ["@function.builtin.bash"] = { fg = colors.cyan.base, bg = colors.none },
        ["@function.call.bash"] = { fg = colors.cyan.base, bg = colors.none },
        ["@operator.bash"] = { fg = colors.cyan.base, bg = colors.none },
        ["@parameter.bash"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@punctuation.delimiter.bash"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@punctuation.special.bash"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@string.regex.bash"] = { fg = colors.yellow.base, bg = colors.none },
        ["@string.regexp.bash"] = { fg = colors.cyan.base, bg = colors.none },
        ["@variable.bash"] = { fg = colors.fg, bg = colors.none },
        ["@variable.parameter.bash"] = { fg = colors.cyan.bright, bg = colors.none, bold = true },
    },

    css = {
        ["@attribute.css"] = { fg = colors.yellow.base, bg = colors.none },
        ["@function.css"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@property.css"] = { fg = colors.fg, bg = colors.none, bold = true },
        ["@punctuation.bracket.css"] = { fg = colors.blue.base, bg = colors.none },
        ["@punctuation.delimiter.css"] = { fg = colors.yellow.base, bg = colors.none },
        ["@string.css"] = { fg = colors.green.base, bg = colors.none },
        ["@tag.attribute.css"] = { fg = colors.yellow.base, bg = colors.none },
        ["@tag.css"] = { fg = colors.blue.base, bg = colors.none },
        ["@type.css"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@variable.css"] = { fg = colors.cyan.base, bg = colors.none },
    },

    docker = {
        ["@property.dockerfile"] = { fg = colors.cyan.bright, bg = colors.none },
    },

    git_config = {
        ["@operator.git_config"] = { fg = colors.yellow.base, bg = colors.none },
        ["@property.git_config"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@string.git_config"] = { fg = colors.green.base, bg = colors.none },
        ["@type.git_config"] = { fg = colors.blue.base, bg = colors.none },
    },

    git_ignore = {
        ["@punctuation.delimiter.gitignore"] = { link = "Comment" },
        ["@string.special.path.gitignore"] = { link = "Comment" },
    },

    go = {
        ["@constant.builtin.go"] = { fg = colors.yellow.base, bg = colors.none },
        ["@constant.go"] = { fg = colors.cyan.base, bg = colors.none },
        ["@field.go"] = { fg = colors.fg, bg = colors.none },
        ["@function.call.go"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@keyword.function.go"] = { fg = colors.blue.base, bg = colors.none },
        ["@lsp.keyword.go"] = { fg = colors.blue.base, bg = colors.none },
        ["@lsp.mod.defaultLibrary.go"] = { fg = colors.yellow.base, bg = colors.none },
        ["@lsp.mod.definition.go"] = { fg = colors.fg, bg = colors.none },
        ["@lsp.mod.readonly.go"] = { fg = colors.cyan.base, bg = colors.none },
        ["@lsp.type.function.go"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@lsp.type.keyword.go"] = { fg = colors.blue.base, bg = colors.none },
        ["@lsp.type.namespace.go"] = { fg = colors.none, bg = colors.none },
        ["@lsp.type.operator.go"] = { fg = colors.yellow.base, bg = colors.none },
        ["@lsp.type.string.go"] = { fg = colors.green.base, bg = colors.none },
        ["@lsp.type.type.go"] = { fg = colors.blue.base, bg = colors.none },
        ["@lsp.type.typeParameter.go"] = { fg = colors.yellow.base, bg = colors.none },
        ["@lsp.type.variable.go"] = { fg = colors.fg, bg = colors.none },
        ["@lsp.typemod.function.definition.go"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@lsp.typemod.method.definition.go"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@lsp.typemod.parameter.definition.go"] = { fg = colors.fg, bg = colors.none },
        ["@lsp.typemod.type.defaultLibrary.go"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@lsp.typemod.type.definition.go"] = { fg = colors.fg, bg = colors.none },
        ["@lsp.typemod.typeParameter.definition.go"] = { fg = colors.yellow.base, bg = colors.none },
        ["@lsp.typemod.variable.defaultLibrary.go"] = { fg = colors.yellow.base, bg = colors.none },
        ["@lsp.typemod.variable.definition.go"] = { fg = colors.fg, bg = colors.none },
        ["@lsp.typemod.variable.readonly.go"] = { fg = colors.yellow.base, bg = colors.none },
        ["@method.call.go"] = { fg = colors.cyan.base, bg = colors.none },
        ["@method.go"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@module.go"] = { fg = colors.fg, bg = colors.none },
        ["@namespace.go"] = { fg = colors.none, bg = colors.none },
        ["@property.go"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@punctuation.bracket.go"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@string.escape.go"] = { fg = colors.yellow.base, bg = colors.none },
        ["@string.go"] = { fg = colors.green.base, bg = colors.none },
        ["@type.builtin.go"] = { fg = colors.blue.dim, bg = colors.none },
        ["@type.definition.go"] = { fg = colors.fg, bg = colors.none },
        ["@type.go"] = { fg = colors.blue.dim, bg = colors.none },
        ["@variable.go"] = { fg = colors.fg, bg = colors.none },
        ["@variable.parameter.go"] = { fg = colors.fg, bg = colors.none },
        ["goBlock"] = { fg = colors.cyan.bright, bg = colors.none },
        ["goConditional"] = { fg = colors.blue.base, bg = colors.none },
        ["goConst"] = { fg = colors.yellow.base, bg = colors.none },
        ["goImport"] = { fg = colors.cyan.base, bg = colors.none },
        ["goImportString"] = { fg = colors.green.base, bg = colors.none },
        ["goParen"] = { fg = colors.fg, bg = colors.none },
    },

    html = {
        ["@constant.html"] = { fg = colors.white.dim, bg = colors.none },
        ["@operator.html"] = { fg = colors.yellow.base, bg = colors.none },
        ["@string.html"] = { fg = colors.green.base, bg = colors.none },
        ["@string.special.url.html"] = { fg = colors.yellow.base, bg = colors.none },
        ["@tag.attribute.html"] = { fg = colors.cyan.base, bg = colors.none, bold = true },
        ["@tag.delimiter.html"] = { link = "@tag.html" },
        ["@tag.html"] = { fg = colors.blue.base, bg = colors.none },
        ["@text.html"] = { fg = colors.fg, bg = colors.none },
        ["@text.uri.html"] = { fg = colors.green.base, bg = colors.none },
        ["htmlEndTag"] = { fg = colors.blue.base, bg = colors.none },
        ["htmlHead"] = { fg = colors.blue.base, bg = colors.none },
        ["htmlScriptTag"] = { fg = colors.blue.base, bg = colors.none },
        ["htmlSpecialTagName"] = { fg = colors.blue.base, bg = colors.none },
        ["htmlTag"] = { fg = colors.blue.base, bg = colors.none },
        ["htmlTagName"] = { fg = colors.blue.base, bg = colors.none },
    },

    json = {
        ["@conceal.json"] = { fg = colors.fg, bg = colors.none, bold = true },
        ["@label.json"] = { fg = colors.green.base, bg = colors.none },
        ["@number.json"] = { fg = colors.magenta.base, bg = colors.none },
        ["@property.json"] = { fg = colors.cyan.base, bg = colors.none },
        ["@punctuation.bracket.json"] = { fg = colors.fg, bg = colors.none },
        ["@punctuation.delimiter.json"] = { fg = colors.fg, bg = colors.none },
        ["@string.escape.json"] = { fg = colors.yellow.base, bg = colors.none },
        ["@string.json"] = { fg = colors.green.base, bg = colors.none },
        ["jsonKeyword"] = { fg = colors.green.base, bg = colors.none, bold = true },
        ["jsonQuote"] = { fg = colors.fg, bg = colors.none },
        ["jsonString"] = { fg = colors.green.base, bg = colors.none, bold = true },
    },

    lua = {
        ["@constant.lua"] = { fg = colors.cyan.base, bg = colors.none },
        ["@constructor.lua"] = { fg = colors.blue.base, bg = colors.none },
        ["@field.lua"] = { fg = colors.fg, bg = colors.none },
        ["@function.call.lua"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@lsp.mod.declaration.lua"] = { fg = colors.fg, bg = colors.none },
        ["@lsp.mod.defaultLibrary.lua"] = { fg = colors.cyan.base, bg = colors.none },
        ["@lsp.mod.global.lua"] = { fg = colors.cyan.base, bg = colors.none },
        ["@lsp.type.comment.lua"] = {},
        ["@lsp.type.method.lua"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@lsp.type.variable.lua"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@lsp.typemod..global.lua"] = { fg = colors.cyan.base, bg = colors.none },
        ["@lsp.typemod.function.declaration.lua"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@lsp.typemod.variable.declaration.lua"] = { fg = colors.fg, bg = colors.none },
        ["@lsp.typemod.variable.defaultLibrary.lua"] = { fg = colors.cyan.base, bg = colors.none },
        ["@lsp.typemod.variable.global.lua"] = { fg = colors.cyan.base, bg = colors.none },
        ["@punctuation.bracket.lua"] = { fg = colors.blue.base, bg = colors.none },
        ["@punctuation.delimiter.lua"] = { fg = colors.fg, bg = colors.none },
        ["@variable.lua"] = { fg = colors.white.dim },
        ["@variable.member.lua"] = { fg = colors.blue.base },
    },

    markdown = {
        ["@_label.markdown"] = { fg = colors.cyan.base, bg = colors.none, bold = true },
        ["@_url.markdown_inline"] = { fg = colors.green.base, bg = colors.none },
        ["@conceal.markdown_inline"] = { fg = colors.yellow.base, bg = colors.none },
        ["@label.markdown"] = { fg = colors.cyan.base, bg = colors.none, bold = true },
        ["@lsp.type.class.markdown"] = { fg = colors.cyan.bright, bg = colors.bg, bold = true },
        ["@markup"] = { fg = colors.white.dim },
        ["@markup.emphasis"] = { fg = colors.white.dim, italic = true },
        ["@markup.heading"] = { fg = colors.cyan.bright, bg = colors.none, sp = colors.blue.base, bold = true },
        ["@markup.italic"] = {},
        ["@markup.italic.markdown_inline"] = { fg = colors.blue.base, bg = colors.none, italic = true },
        ["@markup.link"] = { bold = true, fg = colors.blue.base },
        ["@markup.link.label"] = { link = "Special" },
        ["@markup.link.label.markdown_inline"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@markup.link.markdown_inline"] = { fg = colors.fg, bg = colors.none },
        ["@markup.link.url"] = { link = "@string.special.url" },
        ["@markup.link.url.markdown_inline"] = { link = "Underlined" },
        ["@markup.list"] = { fg = colors.blue.base },
        ["@markup.list.checked"] = { fg = colors.green.base },
        ["@markup.list.markdown"] = { fg = colors.yellow.base, bg = colors.none },
        ["@markup.list.unchecked"] = { fg = colors.yellow.base },
        ["@markup.math"] = { fg = colors.white.bright },
        ["@markup.note"] = { fg = colors.orange.base },
        ["@markup.quote"] = { fg = colors.white.base },
        ["@markup.raw"] = { fg = colors.white.base, italic = true },
        ["@markup.raw.block"] = { fg = colors.magenta.base },
        ["@markup.raw.block.markdown"] = { fg = colors.green.base, bg = colors.none },
        ["@markup.raw.markdown_inline"] = { fg = colors.yellow.base, bg = colors.none },
        ["@markup.strikethrough"] = { fg = colors.white.dim, strikethrough = true },
        ["@markup.strong"] = { bold = true, fg = colors.white.dim },
        ["@markup.strong.markdown_inline"] = { fg = colors.cyan.bright, bg = colors.none, bold = true },
        ["@markup.underline"] = {},
        ["@nospell.markdown_inline"] = { fg = colors.green.base, bg = colors.none },
        ["@punctuation.bracket.markdown_inline"] = { fg = colors.fg, bg = colors.none },
        ["@punctuation.delimiter.markdown"] = { fg = colors.yellow.base, bg = colors.none },
        ["@punctuation.delimiter.markdown_inline"] = { fg = colors.yellow.base, bg = colors.none },
        ["@punctuation.special.markdown"] = { fg = colors.yellow.base, bg = colors.none },
        ["@text.emphasis.markdown_inline"] = { fg = colors.blue.base, bg = colors.none, italic = true },
        ["@text.literal.block.markdown"] = { fg = colors.green.base, bg = colors.none },
        ["@text.literal.markdown"] = { fg = colors.yellow.base, bg = colors.none },
        ["@text.literal.markdown_inline"] = { fg = colors.green.base, bg = colors.none },
        ["@text.quote.markdown"] = { fg = colors.gray.base, bg = colors.none },
        ["@text.reference.markdown"] = { fg = colors.green.base, bg = colors.none, italic = true },
        ["@text.reference.markdown_inline"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@text.strike.markdown_inline"] = { fg = colors.blue.base, bg = colors.none, strikethrough = true },
        ["@text.strong.markdown_inline"] = { fg = colors.cyan.base, bg = colors.none, bold = true },
        ["@text.title.markdown"] = { fg = colors.fg, bg = colors.none },
        ["@text.todo.checked.markdown"] = { fg = colors.green.base, bg = colors.none },
        ["@text.todo.unchecked.markdown"] = { fg = colors.yellow.base, bg = colors.none },
        ["@text.uri.markdown_inline"] = { link = "Underlined" },
        ["markdownUrl"] = { link = "Underlined" },
    },

    rust = {
        ["@lsp.type.function.rust"] = { link = "@function.call" },
        ["@lsp.type.interface.rust"] = {},
        ["@lsp.type.variable.rust"] = { link = "@variable" },
    },

    sql = {
        ["@attribute.sql"] = { fg = colors.magenta.base, bg = colors.none },
        ["@comment.sql"] = { link = "Comment" },
        ["@field.sql"] = { fg = colors.magenta.base, bg = colors.none },
        ["@keyword.operator.sql"] = { fg = colors.blue.base, bg = colors.none },
        ["@keyword.sql"] = { fg = colors.blue.base, bg = colors.none },
        ["@spell.sql"] = { fg = colors.gray.base, bg = colors.none, italic = true },
        ["@type.builtin.sql"] = { fg = colors.cyan.base, bg = colors.none },
        ["@type.qualifier.sql"] = { fg = colors.blue.base, bg = colors.none },
        ["@type.sql"] = { fg = colors.cyan.bright, bg = colors.none },
    },

    toml = {
        ["@comment.toml"] = { link = "Comment" },
        ["@number.toml"] = { fg = colors.magenta.base, bg = colors.none },
        ["@operator.toml"] = { fg = colors.yellow.base, bg = colors.none },
        ["@property.toml"] = { link = "@property" },
        ["@punctuation.bracket.toml"] = { fg = colors.fg, bg = colors.none },
        ["@string.special.toml"] = { fg = colors.yellow.base, bg = colors.none },
        ["@string.toml"] = { fg = colors.green.base, bg = colors.none },
        ["@type.toml"] = { link = "@type" },
    },

    vimdoc = {
        ["@conceal.vimdoc"] = { fg = colors.black.dim, bg = colors.none },
        ["@label.vimdoc"] = { fg = colors.yellow.base, bg = colors.none },
        ["@parameter.vimdoc"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@text.literal.block.vimdoc"] = { fg = colors.cyan.bright, bg = colors.none, bold = true },
        ["@text.literal.vimdoc"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@text.reference.vimdoc"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@text.title.1.vimdoc"] = { fg = colors.blue.base, bg = colors.none },
        ["@text.title.2.vimdoc"] = { fg = colors.blue.base, bg = colors.none },
        ["@text.title.3.vimdoc"] = { fg = colors.blue.base, bg = colors.none },
        ["@text.title.4.vimdoc"] = { fg = colors.cyan.bright, bg = colors.none },
        ["@text.uri.vimdoc"] = { fg = colors.green.base, bg = colors.none, underline = true, sp = colors.green.base },
    },

    xml = {
        ["@punctuation.delimiter.xml"] = { fg = colors.green.base, bg = colors.none },
        ["@string.xml"] = { fg = colors.green.base, bg = colors.none },
        ["@tag.xml"] = { fg = colors.green.base, bg = colors.none },
        ["@tag.attribute"] = { fg = colors.white.bright, italic = true },
        ["@tag.attribute.xml"] = { fg = colors.yellow.base, bg = colors.none },
        ["@tag.builtin"] = { link = "Special" },
        ["@tag.delimiter"] = { fg = colors.cyan.base },
    },

    yaml = {
        ["@comment.yaml"] = { fg = colors.yellow.base, bg = colors.none },
        ["@constant.builtin.yaml"] = { fg = colors.blue.base, bg = colors.none },
        ["@field.yaml"] = { fg = colors.yellow.base, bg = colors.none },
        ["@label.yaml"] = { fg = colors.yellow.base, bg = colors.none },
        ["@number.yaml"] = { fg = colors.magenta.base, bg = colors.none },
        ["@property.yaml"] = { fg = colors.cyan.base, bg = colors.none },
        ["@punctuation.delimiter.yaml"] = { fg = colors.yellow.base, bg = colors.none },
        ["@punctuation.special.yaml"] = { fg = colors.cyan.bright, bg = colors.none, bold = true },
        ["@spell.yaml"] = { fg = colors.gray.base, bg = colors.none },
        ["@string.yaml"] = { fg = colors.green.base, bg = colors.none },
        ["@type.yaml"] = { fg = colors.fg, bg = colors.none, bold = true },
        ["yamlBlockMappingKey"] = { fg = colors.blue.base, bg = colors.none },
        ["yamlBool"] = { fg = colors.blue.base, bg = colors.none },
        ["yamlDocumentStart"] = { fg = colors.blue.base, bg = colors.none },
        ["yamlKey"] = { fg = colors.yellow.base, bg = colors.none },
        ["yamlTSField"] = { fg = colors.red.base, bg = colors.none },
        ["yamlTSPunctSpecial"] = { fg = colors.red.base, bg = colors.none },
        ["yamlTSString"] = { fg = colors.green.base, bg = colors.none },
    },
}

function M.blend_bg(hex, amount)
    return require("snacks.util").blend(hex, colors.bg, amount)
end

function M.darken(hex, amount, bg)
    return require("snacks.util").blend(hex, bg or colors.bg, amount)
end

function M.lighten(hex, amount, fg)
    return require("snacks.util").blend(hex, fg or colors.fg, amount)
end

---@param name string
---@param opts vim.api.keyset.highlight
M.set = function(name, opts)
    vim.api.nvim_set_hl(0, name, opts)
end

---Apply a list of highlights
---@param highlights {[string]: vim.api.keyset.highlight}[]
M.apply = function(highlights)
    --
    vim.schedule(function()
        vim.iter(highlights):each(function(hl)
            M.set(next(hl))
        end)
    end)
end

return M
