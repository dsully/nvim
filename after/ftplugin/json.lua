-- https://medium.com/scoro-engineering/5-smart-mini-snippets-for-making-text-editing-more-fun-in-neovim-b55ffb96325a

keys.map("o", function()
    if string.find(vim.api.nvim_get_current_line(), "[^,{[]$") then
        return "A,<cr>"
    end

    return "o"
end, "Split JSON lines", { buffer = true, expr = true })
