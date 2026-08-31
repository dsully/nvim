vim.g.colors_name = vim.g.colorscheme
vim.o.background = "dark"

vim.cmd.highlight("clear")

---@class LSPSemanticToken
---@field modifiers table<lsp.SemanticTokenModifiers,bool>
---@field type string

local highlights = require("config.highlights")

for _, group in pairs(vim.tbl_extend("force", highlights.ui, highlights.languages, highlights.plugins)) do
    for name, highlight in pairs(group) do
        vim.api.nvim_set_hl(0, name, highlight)
    end
end
