vim.g.colors_name = vim.g.colorscheme
vim.o.background = "dark"

vim.cmd.highlight("clear")

ev.on(ev.LspTokenUpdate, function(args)
    local token = args.data.token

    if token.modifiers.defaultLibrary and token.modifiers.readonly then
        vim.lsp.semantic_tokens.highlight_token(token, args.buf, args.data.client_id, "@lsp.mod.defaultLibrary")
    end

    if token.type == "variable" and token.modifiers.readonly and token.modifiers.definition then
        vim.lsp.semantic_tokens.highlight_token(token, args.buf, args.data.client_id, "@lsp.type.variable")
    end
end)

local highlights = require("config.highlights")

vim.iter(vim.tbl_extend("force", highlights.ui, highlights.languages)):each(function(_, group)
    vim.iter(group):each(function(name, highlight)
        vim.api.nvim_set_hl(0, name, highlight)
    end)
end)
