vim.g.colors_name = vim.g.colorscheme
vim.o.background = "dark"

vim.cmd.highlight("clear")

---@class LSPSemanticToken
---@field modifiers table<lsp.SemanticTokenModifiers,bool>
---@field type string

local highlights = require("config.highlights")

vim.iter(vim.tbl_extend("force", highlights.ui, highlights.languages, highlights.plugins)):each(function(_, group)
    vim.iter(group):each(function(name, highlight)
        vim.api.nvim_set_hl(0, name, highlight)
    end)
end)
