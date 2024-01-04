local defaults = require("config.defaults")

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
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = defaults.icons.error,
            [vim.diagnostic.severity.WARN] = defaults.icons.warn,
            [vim.diagnostic.severity.INFO] = defaults.icons.info,
            [vim.diagnostic.severity.HINT] = defaults.icons.hint,
        },
    },
    severity_sort = true,
    update_in_insert = false, -- https://www.reddit.com/r/neovim/comments/pfk209/nvimlsp_too_fast/
})
