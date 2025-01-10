local M = {
    Added = "DiffAdd", --- Added text in diff
    Boolean = "Boolean", --- Boolean constants
    Changed = "DiffChange", --- Changed text in diff
    Character = "Character", --- Character constants
    ColorColumn = "ColorColumn", --- Color column (set with 'colorcolumn')
    Comment = "Comment", --- Comments
    ComplMatchIns = "ComplMatchIns", --- Completion matches insert
    Conceal = "Conceal", --- Concealed elements
    Conditional = "Conditional", --- Conditional statements
    Constant = "Constant", --- Any constant
    Cursor = "Cursor", --- Cursor in normal mode
    CursorColumn = "CursorColumn", --- Screen column the cursor is in
    CursorIM = "CursorIM", --- Cursor in Insert mode
    CursorLine = "CursorLine", --- Line the cursor is on
    CursorLineFold = "CursorLineFold", --- Fold column at cursor line
    CursorLineNr = "CursorLineNr", --- Line number of the cursor line
    CursorLineSign = "CursorLineSign", --- Sign column at cursor line
    Debug = "Debug", --- Debugging statements
    Define = "Define", --- Preprocessor #define
    Delimiter = "Delimiter", --- Delimiters
    DiagnosticFloatingError = "DiagnosticFloatingError", --- Floating diagnostic error messages
    DiagnosticFloatingHint = "DiagnosticFloatingHint", --- Floating diagnostic hint messages
    DiagnosticFloatingInfo = "DiagnosticFloatingInfo", --- Floating diagnostic info messages
    DiagnosticFloatingOk = "DiagnosticFloatingOk", --- Floating diagnostic ok messages
    DiagnosticFloatingWarn = "DiagnosticFloatingWarn", --- Floating diagnostic warning messages
    DiagnosticSignError = "DiagnosticSignError", --- Signs for errors in sign column
    DiagnosticSignHint = "DiagnosticSignHint", --- Signs for hints in sign column
    DiagnosticSignInfo = "DiagnosticSignInfo", --- Signs for information in sign column
    DiagnosticSignOk = "DiagnosticSignOk", --- Signs for ok messages in sign column
    DiagnosticSignWarn = "DiagnosticSignWarn", --- Signs for warnings in sign column
    DiagnosticUnnecessary = "DiagnosticUnnecessary", --- Unused or unnecessary code
    DiagnosticVirtualTextError = "DiagnosticVirtualTextError", --- Virtual text for errors
    DiagnosticVirtualTextHint = "DiagnosticVirtualTextHint", --- Virtual text for hints
    DiagnosticVirtualTextInfo = "DiagnosticVirtualTextInfo", --- Virtual text for information
    DiagnosticVirtualTextOk = "DiagnosticVirtualTextOk", --- Virtual text for ok messages
    DiagnosticVirtualTextWarn = "DiagnosticVirtualTextWarn", --- Virtual text for warnings
    DiffAdd = "DiffAdd", --- Added line in diff
    DiffChange = "DiffChange", --- Changed line in diff
    DiffDelete = "DiffDelete", --- Deleted line in diff
    DiffText = "DiffText", --- Changed text within a changed line
    Directory = "Directory", --- Directory names in listings
    EndOfBuffer = "EndOfBuffer", --- Filler lines (~) after end of buffer
    ErrorMsg = "ErrorMsg", --- Error messages
    Exception = "Exception", --- Try, catch, throw
    Float = "Float", --- Floating point constants
    FloatBorder = "FloatBorder", --- Border of floating windows
    FloatFooter = "FloatFooter", --- Footer of floating windows
    FloatTitle = "FloatTitle", --- Title of floating windows
    FoldColumn = "FoldColumn", --- Column showing fold markers
    Folded = "Folded", --- Folded text
    Function = "Function", --- Function name (also: methods for classes)
    Identifier = "Identifier", --- Any variable name
    Ignore = "Ignore", --- Left blank, hidden
    IncSearch = "IncSearch", --- 'incsearch' highlighting
    Include = "Include", --- #include, #define, etc.
    Keyword = "Keyword", --- Keywords
    Label = "Label", --- Labels
    LineNr = "LineNr", --- Line numbers
    LineNrAbove = "LineNrAbove", --- Line number above the cursor
    LineNrBelow = "LineNrBelow", --- Line number below the cursor
    LspCodeLens = "LspCodeLens", --- LSP code lens text
    LspCodeLensSeparator = "LspCodeLensSeparator", --- Separator between code lens text
    LspInlayHint = "LspInlayHint", --- LSP inlay hint text
    LspReferenceRead = "LspReferenceRead", --- Used for highlighting "read" references
    LspReferenceTarget = "LspReferenceTarget", --- Used for highlighting target references
    LspReferenceText = "LspReferenceText", --- Used for highlighting "text" references
    LspReferenceWrite = "LspReferenceWrite", --- Used for highlighting "write" references
    LspSignatureActiveParameter = "LspSignatureActiveParameter", --- Used for highlighting active parameter in signature help
    Macro = "Macro", --- Same as Define
    MatchParen = "MatchParen", --- Characters under the cursor in CTRL-X mode
    ModeMsg = "ModeMsg", --- Mode messages (e.g., "-- INSERT --")
    MoreMsg = "MoreMsg", --- More-prompt (e.g., -- More -- in command output)
    MsgArea = "MsgArea", --- Area for messages and cmdline
    MsgSeparator = "MsgSeparator", --- Separator in message area
    NONE = "NONE",
    NonText = "NonText", --- Non-text characters
    Normal = "Normal", --- Normal text
    NormalFloat = "NormalFloat", --- Normal text in floating windows
    NormalNC = "NormalNC", --- Normal text in non-current windows
    Number = "Number", --- Number constants
    Operator = "Operator", --- Operators
    Pmenu = "Pmenu", --- Popup menu: normal item
    PmenuExtra = "PmenuExtra", --- Extra text in popup menu
    PmenuExtraSel = "PmenuExtraSel", --- Selected extra text in popup menu
    PmenuKind = "PmenuKind", --- Kind text in popup menu
    PmenuKindSel = "PmenuKindSel", --- Selected kind text in popup menu
    PmenuMatch = "PmenuMatch", --- Matched chars in popup menu
    PmenuMatchSel = "PmenuMatchSel", --- Selected matched chars in popup menu
    PmenuSbar = "PmenuSbar", --- Scrollbar of popup menu
    PmenuSel = "PmenuSel", --- Selected item in popup menu
    PreCondit = "PreCondit", --- Preprocessor #if, #else, #endif, etc.
    PreProc = "PreProc", --- Generic Preprocessor
    Question = "Question", --- Question-prompt
    QuickFixLine = "QuickFixLine", --- Current quickfix item
    RedrawDebugNormal = "RedrawDebugNormal", --- Used for highlighting screen redraws
    Removed = "DiffDelete", --- Removed text in diff
    Repeat = "Repeat", --- Loop statements
    Search = "Search", --- Search highlighting
    SignColumn = "SignColumn", --- Sign column
    SnippetTabstop = "SnippetTabstop", --- Used for snippet tabstops
    Special = "Special", --- Any special symbol
    SpecialChar = "SpecialChar", --- Special characters in strings
    SpecialComment = "SpecialComment", --- Special things inside comments
    SpecialKey = "SpecialKey", --- Special keys listed in |:help|
    SpellBad = "SpellBad", --- Words that should start with capital
    SpellCap = "SpellCap", --- Words that should start with capital
    SpellLocal = "SpellLocal", --- Wrong spelling for selected region
    SpellRare = "SpellRare", --- Words that are rare
    Statement = "Statement", --- Any statement
    StatusLine = "StatusLine", --- Status line of current window
    StatusLineNC = "StatusLineNC", --- Status lines of not-current windows
    StatusLineTerm = "StatusLineTerm", --- Status line of terminal windows
    StatusLineTermNC = "StatusLineTermNC", --- Status line of non-current terminal windows
    StorageClass = "StorageClass", --- static, register, volatile, etc.
    String = "String", --- String constants
    Structure = "Structure", --- struct, union, enum, etc.
    Substitute = "Substitute", --- Text replaced with :substitute
    TabLine = "TabLine", --- Tab pages line
    TabLineFill = "TabLineFill", --- Tab pages line filler
    TabLineSel = "TabLineSel", --- Active tab in tab line
    Tag = "Tag", --- HTML tags, XML tags, etc.
    TermCursor = "TermCursor", --- Cursor in terminal mode
    TermCursorNC = "TermCursorNC", --- Cursor in an unfocused terminal
    Title = "Title", --- Titles for output from ":set all", ":autocmd" etc.
    Todo = "Todo", --- Things that need extra attention
    Type = "Type", --- Any type
    Typedef = "Typedef", --- A typedef
    Underlined = "Underlined", --- Text that is underlined
    VertSplit = "VertSplit", --- Vertical separator between windows
    Visual = "Visual", --- Visual mode selection
    VisualNOS = "VisualNOS", --- Visual mode selection when vim is "Not Owning the Selection"
    WarningMsg = "WarningMsg", --- Warning messages
    Whitespace = "Whitespace", --- Whitespace characters
    WildMenu = "WildMenu", --- Current match in 'wildmenu' completion
    WinSeparator = "WinSeparator", --- Window separator between windows
    lCursor = "lCursor", --- Cursor in language mapping
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

---Apply a list of highlights
---@param highlights table<string, vim.api.keyset.highlight>
M.apply = function(highlights)
    --
    ---@param name string
    ---@param opts vim.api.keyset.highlight
    vim.iter(highlights):each(function(name, opts)
        vim.api.nvim_set_hl(0, name, opts)
    end)
end

return M
