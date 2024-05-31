local M = {
    title = "rust-analyzer",
}

-- Format the expanded macro output and open it in a float.
---@param macro ExpandedMacro
M.expand_macro = function(macro)
    local header = ("// Rescursive expansion of `%s` macro:"):format(macro.name)

    local lines = vim.iter({
        header,
        "// " .. string.rep("=", #header - 3),
        "",
        vim.split(macro.expansion, "\n", { plain = true, trimempty = true }),
    })
        :flatten()
        :totable()

    require("helpers.float").open({ filetype = "rust", lines = lines, width = 0.8 })

    -- Move cursor to the start of the macro expansion.
    vim.api.nvim_win_set_cursor(0, { 4, 0 })
end
