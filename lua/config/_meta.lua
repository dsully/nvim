---@meta
error("Cannot require a meta file")

---CompletionItem.data that rust-analyzer returns.
---@class RustCompletionImport
---@field full_import_path string
---@field imported_name string

---@class RustCompletionResolveData
---@field imports RustCompletionImport[]
---@field position lsp.TextDocumentPositionParams

---@alias RustData RustCompletionResolveData | nil
