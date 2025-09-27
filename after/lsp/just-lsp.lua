---@type vim.lsp.Config
--- https://github.com/terror/just-lsp
---
--- `just-lsp` is an LSP for just built on top of the tree-sitter-just parser.
return {
    cmd = { "just-lsp" },
    filetypes = { "just" },
    root_markers = { "Justfile", "justfile" },
    single_file_support = true,
}
