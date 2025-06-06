---@meta
error("Cannot require a meta file")

---@class LuaLanguageServerSettings
---@field runtime.version "Lua 5.1"|"Lua 5.2"|"Lua 5.3"|"Lua 5.4"|"LuaJIT"?
---@field runtime.path string[]? # Default: ["?.lua", "?/init.lua"]
---@field runtime.pathStrict boolean? # Default: false
---@field runtime.special table<string,string>? # Special global variables
---@field runtime.meta string? # Default: "${version} ${language} ${encoding}"
---@field runtime.unicodeName boolean?
---@field runtime.nonstandardSymbol string[]? # Non-standard symbols like '//', '+=', etc
---@field runtime.plugin string?|string[]? # Plugin path(s)
---@field runtime.pluginArgs string[]?|table<string,string>? # Plugin arguments
---@field runtime.fileEncoding "utf8"|"ansi"|"utf16le"|"utf16be"? # Default: "utf8"
---@field runtime.builtin table<string,string>? # Built-in library config
---@field diagnostics.enable boolean? # Default: true
---@field diagnostics.globals string[]? # Global variables
---@field diagnostics.globalsRegex string[]? # Global variables regex patterns
---@field diagnostics.disable string[]? # Disabled diagnostic codes
---@field diagnostics.severity table<string,"Error"|"Warning"|"Information"|"Hint">? # Diagnostic severities
---@field diagnostics.workspaceEvent "OnChange"|"OnSave"|"None"? # Default: "OnSave"
---@field diagnostics.workspaceDelay integer? # Default: 3000
---@field diagnostics.workspaceRate integer? # Default: 100
---@field diagnostics.libraryFiles "Enable"|"Opened"|"Disable"? # Default: "Opened"
---@field diagnostics.ignoredFiles "Enable"|"Opened"|"Disable"? # Default: "Opened"
---@field diagnostics.unusedLocalExclude string[]?
---@field workspace.ignoreDir string[]? # Default: [".vscode"]
---@field workspace.ignoreSubmodules boolean? # Default: true
---@field workspace.useGitIgnore boolean? # Default: true
---@field workspace.maxPreload integer? # Default: 5000
---@field workspace.preloadFileSize integer? # Default: 500
---@field workspace.library string[]? # Additional library paths
---@field workspace.checkThirdParty "Ask"|"Apply"|"ApplyInMemory"|"Disable"|boolean? # Default: "Ask"
---@field workspace.userThirdParty string[]?
---@field completion.enable boolean? # Default: true
---@field completion.callSnippet "Disable"|"Both"|"Replace"? # Default: "Disable"
---@field completion.keywordSnippet "Disable"|"Both"|"Replace"? # Default: "Replace"
---@field completion.displayContext integer? # Default: 0
---@field completion.workspaceWord boolean? # Default: true
---@field completion.showWord "Enable"|"Fallback"|"Disable"? # Default: "Fallback"
---@field completion.autoRequire boolean? # Default: true
---@field completion.showParams boolean? # Default: true
---@field completion.requireSeparator string? # Default: "."
---@field completion.postfix string? # Default: "@"
---@field signatureHelp.enable boolean? # Default: true
---@field hover.enable boolean? # Default: true
---@field hover.viewString boolean? # Default: true
---@field hover.viewStringMax integer? # Default: 1000
---@field hover.viewNumber boolean? # Default: true
---@field hover.previewFields integer? # Default: 10
---@field hover.enumsLimit integer? # Default: 5
---@field hover.expandAlias boolean? # Default: true
---@field semantic.enable boolean? # Default: true
---@field semantic.variable boolean? # Default: true
---@field semantic.annotation boolean? # Default: true
---@field semantic.keyword boolean? # Default: false
---@field hint.enable boolean? # Default: false
---@field hint.paramType boolean? # Default: true
---@field hint.setType boolean? # Default: false
---@field hint.paramName "All"|"Literal"|"Disable"? # Default: "All"
---@field hint.await boolean? # Default: true
---@field hint.arrayIndex "Enable"|"Auto"|"Disable"? # Default: "Auto"
---@field hint.semicolon "All"|"SameLine"|"Disable"? # Default: "SameLine"
---@field window.statusBar boolean? # Default: true
---@field window.progressBar boolean? # Default: true
---@field codeLens.enable boolean? # Default: false
---@field format.enable boolean? # Default: true
---@field format.defaultConfig table<string,string>? # Default: {}
---@field typeFormat.config table<string,string>? # Default formatting config
---@field spell.dict string[]?
---@field nameStyle.config table<string,string|table[]>?
---@field misc.parameters string[]?
---@field misc.executablePath string?
---@field language.fixIndent boolean? # Default: true
---@field language.completeAnnotation boolean? # Default: true
---@field type.castNumberToInteger boolean? # Default: true
---@field type.weakUnionCheck boolean? # Default: false
---@field type.weakNilCheck boolean? # Default: false
---@field type.inferParamType boolean? # Default: false
---@field type.checkTableShape boolean? # Default: false
---@field type.inferTableSize integer? # Default: 10
---@field doc.privateName string[]?
---@field doc.protectedName string[]?
---@field doc.packageName string[]?
---@field doc.regengine "glob"|"lua"? # Default: "glob"

---CompletionItem.data that rust-analyzer returns.
---@class RustCompletionImport
---@field full_import_path string
---@field imported_name string

---@class RustCompletionResolveData
---@field imports RustCompletionImport[]
---@field position lsp.TextDocumentPositionParams

---@alias RustData RustCompletionResolveData | nil
