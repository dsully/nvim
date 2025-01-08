-- Toggle check boxes.
keys.bmap("<space>tc", function()
    local char = defaults.icons.misc.check
    local current_line = vim.api.nvim_get_current_line()

    local _, _, current_state = string.find(current_line, "%[([ " .. char .. string.upper(char) .. "])%]")

    if current_state then
        local new_state = current_state == " " and char or " "
        local new_line = string.gsub(current_line, "%[.-%]", "[" .. new_state .. "]")

        vim.api.nvim_set_current_line(new_line)
    end
end, "Checkbox", 0, "n", { noremap = true, silent = true })
