local M = {}

---@param name string
---@param opts vim.api.keyset.highlight
M.set = function(name, opts)
    vim.api.nvim_set_hl(0, name, opts)
end

---Apply a list of highlights
---@param highlights {[string]: vim.api.keyset.highlight}[]
M.apply = function(highlights)
    --
    vim.schedule(function()
        vim.iter(highlights):each(function(hl)
            M.set(next(hl))
        end)
    end)
end

return M
