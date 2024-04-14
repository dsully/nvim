vim.g.colors_name = "nordish"
vim.o.background = "dark"

vim.cmd.highlight("clear")

local colors = require("config.defaults").colors

for name, opts in pairs({
    Added = { fg = colors.green.base },
    Bold = { bold = true },
    Boolean = { link = "Number" },
    Changed = { fg = colors.blue.base },
    Character = { link = "String" },
    CmpDocumentation = { bg = colors.black.base, fg = colors.white.base },
    CmpDocumentationBorder = { bg = colors.black.base, fg = colors.gray.bright },
    CmpGhostText = { link = "Comment" },
    CmpItemAbbr = { fg = colors.white.dim },
    CmpItemAbbrDeprecated = { fg = colors.gray.base, strikethrough = true },
    CmpItemAbbrMatch = { bold = true, fg = colors.blue.base },
    CmpItemAbbrMatchFuzzy = { bold = true, fg = colors.blue.base },
    CmpItemKind = { fg = colors.white.bright },
    CmpItemKindClass = { fg = colors.yellow.base },
    CmpItemKindColor = { link = "CmpItemKind" },
    CmpItemKindConstant = { fg = colors.orange.base },
    CmpItemKindConstructor = { fg = colors.yellow.base },
    CmpItemKindEnum = { fg = colors.yellow.base },
    CmpItemKindEnumMember = { fg = colors.cyan.base },
    CmpItemKindEvent = { fg = colors.magenta.base },
    CmpItemKindField = { fg = colors.blue.base },
    CmpItemKindFile = { link = "CmpItemKind" },
    CmpItemKindFolder = { link = "CmpItemKind" },
    CmpItemKindFunction = { fg = colors.magenta.base },
    CmpItemKindInterface = { fg = colors.yellow.base },
    CmpItemKindKeyword = { fg = colors.magenta.base },
    CmpItemKindMethod = { fg = colors.magenta.base },
    CmpItemKindModule = { fg = colors.blue.base },
    CmpItemKindOperator = { fg = colors.magenta.base },
    CmpItemKindProperty = { fg = colors.blue.base },
    CmpItemKindReference = { fg = colors.magenta.base },
    CmpItemKindSnippet = { fg = colors.white.base },
    CmpItemKindStruct = { fg = colors.yellow.base },
    CmpItemKindText = { link = "CmpItemKind" },
    CmpItemKindTypeParameter = { fg = colors.yellow.base },
    CmpItemKindUnit = { fg = colors.magenta.base },
    CmpItemKindValue = { fg = colors.blue.base },
    CmpItemKindVariable = { fg = colors.blue.base },
    CmpItemMenu = { fg = colors.magenta.base },
    ColorColumn = { bg = colors.black.dim },
    Comment = { fg = colors.gray.bright, italic = true },
    Conceal = { fg = colors.black.bright },
    Conditional = { fg = colors.blue.bright, italic = true },
    Constant = { fg = colors.white.dim },
    CurSearch = { link = "IncSearch" },
    Cursor = { bg = colors.white.dim, fg = colors.black.dim },
    CursorColumn = { link = "CursorLine" },
    CursorIM = { link = "Cursor" },
    CursorLine = { bg = colors.gray.base },
    CursorLineFold = { link = "FoldColumn" },
    CursorLineNr = { bold = true, fg = colors.yellow.base },
    CursorLineSign = { link = "SignColumn" },
    Debug = { link = "Special" },
    Define = { link = "PreProc" },
    Delimiter = { link = "Special" },
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
    DiagnosticUnnecessary = { link = "Comment" },
    DiagnosticWarn = { fg = colors.yellow.base },
    DiffAdd = { bg = colors.green.base },
    DiffChange = { bg = colors.yellow.base },
    DiffDelete = { bg = colors.red.base },
    DiffText = { bg = colors.red.base },
    Directory = { fg = colors.white.bright },
    EndOfBuffer = { fg = colors.black.dim },
    Error = { fg = colors.red.base },
    ErrorMsg = { fg = colors.red.base },
    Exception = { link = "Keyword" },
    Float = { link = "Number" },
    FloatBorder = { fg = colors.gray.base },
    FloatFooter = { link = "FloatTitle" },
    FloatShadow = { bg = colors.gray.base, blend = 80 },
    FloatShadowThrough = { bg = colors.gray.base, blend = 100 },
    FloatTitle = { fg = colors.white.bright },
    FocusedSymbol = { link = "Search" },
    FoldColumn = { fg = colors.gray.base },
    Folded = { bg = colors.black.dim, fg = colors.gray.base },
    Function = { fg = colors.white.bright, italic = true },
    Identifier = { fg = colors.white.base },
    Ignore = { link = "Normal" },
    IncSearch = { bg = colors.blue.bright, fg = colors.black.dim },
    Include = { link = "PreProc" },
    Italic = { italic = true },
    Keyword = { fg = colors.blue.base, italic = true },
    Label = { link = "Conditional" },
    LineNr = { fg = colors.gray.base },
    LineNrAbove = { link = "LineNr" },
    LineNrBelow = { link = "LineNr" },
    LspCodeLens = { fg = colors.gray.bright },
    LspCodeLensSeparator = { fg = colors.gray.base },
    LspFloatWinBorder = { fg = colors.gray.base },
    LspFloatWinNormal = { bg = colors.black.base },
    LspInfoBorder = { default = true, link = "Label" },
    LspInlayHint = { fg = colors.gray.bright },
    LspReferenceRead = { bg = colors.gray.base },
    LspReferenceText = { bg = colors.gray.base },
    LspReferenceWrite = { bg = colors.gray.base },
    LspSignatureActiveParameter = { fg = colors.gray.base },
    LspTroubleCount = { bg = colors.gray.base, fg = colors.magenta.base },
    LspTroubleNormal = { bg = colors.black.base, fg = colors.gray.base },
    LspTroubleText = { fg = colors.white.base },
    Macro = { link = "PreProc" },
    MatchBackground = { link = "ColorColumn" },
    MatchParen = { bg = colors.gray.base, fg = colors.cyan.bright },
    MatchParenCur = { link = "MatchParen" },
    MatchWord = { link = "MatchParen" },
    ModeMsg = { bold = true, fg = colors.white.dim },
    ModesCopy = { bg = colors.yellow.base },
    ModesDelete = { bg = colors.red.base },
    ModesInsert = { bg = colors.cyan.base },
    ModesVisual = { bg = colors.magenta.base },
    MoreMsg = { bold = true, fg = colors.cyan.bright },
    MsgArea = {},
    MsgSeparator = { link = "StatusLine" },
    NagicIconsOperator = { link = "Operator" },
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
    NeotestAdapterName = { bold = true, fg = colors.magenta.base },
    NeotestDir = { fg = colors.cyan.base },
    NeotestExpandMarker = { link = "Conceal" },
    NeotestFailed = { fg = colors.red.base },
    NeotestFile = { fg = colors.blue.base },
    NeotestFocused = { underline = true },
    NeotestIndent = { link = "Conceal" },
    NeotestMarked = { bold = true, fg = colors.white.dim },
    NeotestNamespace = { fg = colors.cyan.base },
    NeotestPassed = { fg = colors.green.base },
    NeotestRunning = { fg = colors.orange.base },
    NeotestSkipped = { fg = colors.yellow.base },
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
    NoiceFormatLevelError = { fg = colors.red.base },
    NoiceFormatLevelInfo = { fg = colors.blue.base },
    NoiceFormatLevelOff = { default = true, link = "NonText" },
    NoiceFormatLevelTrace = { default = true, link = "NonText" },
    NoiceFormatLevelWarn = { fg = colors.yellow.base },
    NoiceFormatProgressDone = { bg = colors.black.dim, fg = colors.white.bright },
    NoiceFormatProgressTodo = { bg = colors.black.dim, fg = colors.white.bright },
    NoiceFormatTitle = { default = true, link = "Title" },
    NoiceHiddenCursor = { blend = 100, nocombine = true },
    NoiceLspProgressClient = { fg = colors.blue.base },
    NoiceLspProgressSpinner = { fg = colors.cyan.bright },
    NoiceLspProgressTitle = { fg = colors.white.bright },
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
    NoiceVirtualText = { fg = colors.blue.base },
    NonText = { fg = colors.white.base },
    Normal = { bg = colors.black.dim, fg = colors.white.dim },
    NormalFloat = { bg = colors.black.dim, fg = colors.white.dim },
    NormalNC = { bg = colors.black.dim, fg = colors.white.dim },
    NotifyBackground = { link = "NormalFloat" },
    NotifyDEBUGBody = { link = "Normal" },
    NotifyDEBUGBorder = { fg = colors.white.base },
    NotifyDEBUGIcon = { link = "NotifyDEBUGTitle" },
    NotifyDEBUGTitle = { fg = colors.blue.bright },
    NotifyERRORBody = { link = "Normal" },
    NotifyERRORBorder = { fg = colors.red.base },
    NotifyERRORIcon = { link = "NotifyERRORTitle" },
    NotifyERRORTitle = { fg = colors.red.base },
    NotifyINFOBody = { link = "Normal" },
    NotifyINFOBorder = { fg = colors.gray.base },
    NotifyINFOIcon = { link = "NotifyINFOTitle" },
    NotifyINFOTitle = { fg = colors.blue.base },
    NotifyLogTime = { link = "Comment" },
    NotifyLogTitle = { link = "Special" },
    NotifyTRACEBody = { link = "Normal" },
    NotifyTRACEBorder = { fg = colors.black.bright },
    NotifyTRACEIcon = { link = "NotifyTRACETitle" },
    NotifyTRACETitle = { fg = colors.gray.bright },
    NotifyWARNBody = { link = "Normal" },
    NotifyWARNBorder = { fg = colors.yellow.base },
    NotifyWARNIcon = { link = "NotifyWARNTitle" },
    NotifyWARNTitle = { fg = colors.yellow.base },
    Number = { fg = colors.magenta.base },
    Operator = { fg = colors.blue.base },
    Pmenu = { bg = colors.gray.base, fg = colors.white.dim },
    PmenuExtra = { link = "Pmenu" },
    PmenuExtraSel = { link = "PmenuSel" },
    PmenuKind = { link = "Pmenu" },
    PmenuKindSel = { link = "PmenuSel" },
    PmenuSbar = { link = "Pmenu" },
    PmenuSel = { bg = colors.gray.base },
    PmenuThumb = { bg = colors.gray.base },
    PreCondit = { link = "PreProc" },
    PreProc = { fg = colors.blue.bright },
    Question = { link = "MoreMsg" },
    QuickFixLine = { link = "CursorLine" },
    Removed = { fg = colors.red.base },
    Repeat = { link = "Conditional" },
    Search = { bg = colors.gray.base, fg = colors.white.dim },
    SignColumn = { fg = colors.gray.base },
    SignColumnSB = { link = "SignColumn" },
    SnippetTabstop = { link = "Visual" },
    Special = { fg = colors.white.bright },
    SpecialChar = { link = "Special" },
    SpecialComment = { link = "Special" },
    SpecialKey = { link = "NonText" },
    SpellBad = { sp = colors.red.base, undercurl = true },
    SpellCap = { sp = colors.yellow.base, undercurl = true },
    SpellLocal = { sp = colors.blue.base, undercurl = true },
    SpellRare = { sp = colors.blue.base, undercurl = true },
    Statement = { fg = colors.blue.base, italic = true },
    StatusLine = { bg = colors.gray.base, fg = colors.cyan.bright },
    StatusLineNC = { bg = colors.black.base, fg = colors.gray.base },
    StorageClass = { link = "Type" },
    String = { fg = colors.green.base },
    Structure = { link = "Type" },
    Substitute = { bg = colors.red.base, fg = colors.black.dim },
    TabLine = { bg = colors.black.dim, fg = colors.white.base },
    TabLineFill = { bg = colors.black.base },
    TabLineSel = { bg = colors.gray.base, fg = colors.black.dim },
    Tag = { link = "Special" },
    TermCursor = { reverse = true },
    TermCursorNC = {},
    Terminal = { bg = colors.black.dim, fg = colors.white.dim },
    Title = { bold = true, fg = colors.white.bright },
    Todo = { bg = colors.blue.base, fg = colors.black.dim },
    Type = { fg = colors.cyan.base, italic = true },
    Typedef = { link = "Type" },
    Underlined = { underline = true },
    UnderlinedTitle = { bold = true, underline = true },
    VertSplit = { link = "WinSeparator" },
    Visual = { bg = colors.gray.base },
    VisualNOS = { link = "Visual" },
    WarningMsg = { fg = colors.yellow.base },
    WhichKey = { link = "Identifier" },
    WhichKeyBorder = { default = true, link = "FloatBorder" },
    WhichKeyDesc = { link = "Keyword" },
    WhichKeyFloat = { link = "NormalFloat" },
    WhichKeyGroup = { link = "Function" },
    WhichKeySeparator = { link = "Comment" },
    WhichKeyValue = { link = "Comment" },
    Whitespace = { fg = colors.gray.base },
    WildMenu = { link = "Pmenu" },
    WinBar = { link = "StatusLine" },
    WinBarNC = { link = "StatusLineNC" },
    WinSeparator = { fg = colors.black.base },
    ["@attribute"] = { fg = colors.blue.base },
    ["@attribute.builtin"] = { link = "Special" },
    ["@boolean"] = { link = "Boolean" },
    ["@character"] = { link = "Character" },
    ["@character.special"] = { link = "SpecialChar" },
    ["@comment"] = { link = "Comment" },
    ["@comment.error"] = { fg = colors.red.base },
    ["@comment.note"] = { fg = colors.blue.base },
    ["@comment.todo"] = { fg = colors.orange.base },
    ["@comment.warning"] = { fg = colors.yellow.base },
    ["@conditional"] = { link = "Conditional" },
    ["@constant"] = { link = "Constant" },
    ["@constant.builtin"] = { fg = colors.blue.base, italic = true },
    ["@constant.macro"] = { link = "Macro" },
    ["@constructor"] = { fg = colors.white.base, italic = true },
    ["@constructor.lua"] = { fg = colors.white.base },
    ["@diff.delta"] = { fg = colors.yellow.base },
    ["@diff.minus"] = { fg = colors.red.base },
    ["@diff.plus"] = { fg = colors.green.base },
    ["@exception"] = { link = "Exception" },
    ["@field"] = { fg = colors.blue.base },
    ["@field.rust"] = { fg = colors.white.base },
    ["@float"] = { link = "Float" },
    ["@function"] = { link = "Function" },
    ["@function.builtin"] = { fg = colors.blue.base, italic = true },
    ["@function.macro"] = { fg = colors.blue.base, italic = true },
    ["@include"] = { link = "Include" },
    ["@keyword"] = { link = "Keyword" },
    ["@keyword.conditional"] = { link = "Conditional" },
    ["@keyword.conditional.ternary"] = { link = "Conditional" },
    ["@keyword.exception"] = { fg = colors.blue.base },
    ["@keyword.function"] = { fg = colors.blue.base, italic = true },
    ["@keyword.import"] = { link = "Include" },
    ["@keyword.operator"] = { fg = colors.blue.base },
    ["@keyword.repeat"] = { fg = colors.blue.base, italic = true },
    ["@keyword.return"] = { fg = colors.blue.base, italic = true },
    ["@keyword.storage"] = { link = "StorageClass" },
    ["@label"] = { link = "Label" },
    ["@label.json"] = { fg = colors.white.bright },
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
    ["@lsp.type.interface"] = { fg = colors.red.base },
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
    ["@markup"] = { fg = colors.white.dim },
    ["@markup.emphasis"] = { fg = colors.white.dim, italic = true },
    ["@markup.heading"] = { link = "Title" },
    ["@markup.italic"] = {},
    ["@markup.link"] = { bold = true, fg = colors.blue.base },
    ["@markup.link.label"] = { link = "Special" },
    ["@markup.link.url"] = { link = "@string.special.url" },
    ["@markup.list"] = { fg = colors.blue.base },
    ["@markup.list.checked"] = { fg = colors.green.base },
    ["@markup.list.unchecked"] = { fg = colors.yellow.base },
    ["@markup.math"] = { fg = colors.white.bright },
    ["@markup.note"] = { fg = colors.orange.base },
    ["@markup.quote"] = { fg = colors.white.base },
    ["@markup.raw"] = { fg = colors.white.base, italic = true },
    ["@markup.raw.block"] = { fg = colors.magenta.base },
    ["@markup.strikethrough"] = { fg = colors.white.dim, strikethrough = true },
    ["@markup.strong"] = { bold = true, fg = colors.white.dim },
    ["@markup.underline"] = {},
    ["@module"] = { fg = colors.cyan.base, italic = true },
    ["@module.builtin"] = { link = "Special" },
    ["@namespace"] = { fg = colors.cyan.base },
    ["@number"] = { link = "Number" },
    ["@number.float"] = { link = "Float" },
    ["@operator"] = { link = "Operator" },
    ["@parameter"] = { fg = colors.cyan.base },
    ["@property"] = { fg = colors.blue.base },
    ["@punctuation"] = { link = "Delimiter" },
    ["@punctuation.bracket"] = { fg = colors.blue.base },
    ["@punctuation.delimiter"] = { fg = colors.blue.base },
    ["@punctuation.special"] = { fg = colors.cyan.base },
    ["@repeat"] = { link = "Repeat" },
    ["@storageclass"] = { link = "StorageClass" },
    ["@string"] = { link = "String" },
    ["@string.escape"] = { bold = true, fg = colors.gray.bright },
    ["@string.regex"] = { fg = colors.gray.bright },
    ["@string.regexp"] = { fg = colors.gray.bright },
    ["@string.special"] = { link = "Special" },
    ["@string.special.url"] = { fg = colors.white.dim },
    ["@tag"] = { fg = colors.blue.base },
    ["@tag.attribute"] = { fg = colors.white.bright, italic = true },
    ["@tag.builtin"] = { link = "Special" },
    ["@tag.delimiter"] = { fg = colors.cyan.base },
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
    ["@type"] = { link = "Type" },
    ["@type.builtin"] = { fg = colors.cyan.base, italic = true },
    ["@variable"] = { fg = colors.white.dim },
    ["@variable.builtin"] = { fg = colors.blue.base },
    ["@variable.member"] = { fg = colors.blue.base },
    ["@variable.parameter"] = { fg = colors.yellow.base, italic = true },
    ["@variable.parameter.builtin"] = { link = "Special" },
}) do
    vim.api.nvim_set_hl(0, name, opts)
end
