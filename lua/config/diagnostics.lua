local defaults = require("config.defaults")

local function sign(opts)
    vim.fn.sign_define(opts.highlight, {
        text = opts.icon,
        texthl = opts.highlight,
        numhl = opts.linehl ~= false and opts.highlight .. "Nr" or nil,
        culhl = opts.linehl ~= false and opts.highlight .. "CursorNr" or nil,
        linehl = opts.linehl ~= false and opts.highlight .. "Line" or nil,
    })
end

sign({ highlight = "DiagnosticSignError", icon = defaults.icons.error })
sign({ highlight = "DiagnosticSignWarn", icon = defaults.icons.warn })
sign({ highlight = "DiagnosticSignInfo", linehl = false, icon = defaults.icons.info })
sign({ highlight = "DiagnosticSignHint", linehl = false, icon = defaults.icons.hint })

-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#show-source-in-diagnostics
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#change-prefixcharacter-preceding-the-diagnostics-virtual-text
vim.diagnostic.config({
    float = {
        border = vim.g.border,
        focusable = true,
        header = { " Issues:" },
        max_height = math.min(math.floor(vim.o.lines * 0.3), 30),
        max_width = math.min(math.floor(vim.o.columns * 0.7), 100),
        prefix = function(diag)
            local level = vim.diagnostic.severity[diag.severity]
            local prefix = string.format("%s ", defaults.icons[level:lower()])
            return prefix, "Diagnostic" .. level:gsub("^%l", string.upper)
        end,
        source = "if_many",
        suffix = function(diag)
            if package.loaded["rulebook"] then
                return require("rulebook").hasDocs(diag) and "  " or ""
            end
        end,
    },
    underline = true,
    signs = true,
    severity_sort = true,
    update_in_insert = false, -- https://www.reddit.com/r/neovim/comments/pfk209/nvimlsp_too_fast/
})
