-- General diagnostics.
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "󰙨󰙨 Next Diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "󰙨󰙨 Previous Diagnostic" })
vim.keymap.set("n", "<leader>xr", vim.diagnostic.reset, { desc = " Reset" })
vim.keymap.set("n", "<leader>xs", vim.diagnostic.open_float, { desc = "󰙨 Show" })

-- Buffers
vim.keymap.set("n", "]b", vim.cmd.bnext, { desc = " Next Buffer" })
vim.keymap.set("n", "[b", vim.cmd.bprev, { desc = " Previous Buffer" })

-- Save in insert mode
vim.keymap.set("i", "<C-s>", "<cmd>:w<cr><esc>", { desc = "Save in Insert Mode" })
vim.keymap.set("n", "<C-s>", "<cmd>:w<cr><esc>", { desc = "Save in Normal Mode" })
vim.keymap.set("n", "<C-c>", "<cmd>normal! ciw<cr>a", { desc = "Change in Word" })

-- Quitting / Sessions
vim.keymap.set("n", "qq", vim.cmd.quitall, { desc = "Quit" })
vim.keymap.set("n", "qw", vim.cmd.wqall, { desc = "Quit & Write All" })
vim.keymap.set("n", "q!", function()
    vim.cmd.quitall({ bang = true })
end, { desc = "Quit without saving" })

-- Disable recording / annoying exmode.
-- https://stackoverflow.com/questions/1527784/what-is-vim-recording-and-how-can-it-be-disabled
vim.keymap.set("n", "q", "<Nop>", { desc = "hidden" })
vim.keymap.set("n", "Q", "<Nop>", { desc = "hidden" })
vim.keymap.set("n", "q:", "<Nop>", { desc = "hidden" })

vim.keymap.set("n", "<leader>a", "<cmd>%y<cr>", { desc = "Yank All Lines" })

-- https://www.reddit.com/r/neovim/comments/w0jzzv/smart_dd/
vim.keymap.set("n", "dd", function()
    if vim.api.nvim_get_current_line():match("^%s*$") then
        return '"_dd'
    end
    return "dd"
end, { noremap = true, expr = true })

vim.api.nvim_create_autocmd({ "FileType" }, {
    desc = "Keymap for removing backslashes when joining lines.",
    pattern = { "bash", "fish", "make", "sh", "zsh" },
    callback = function()
        vim.keymap.set("n", "J", function()
            --
            return vim.endswith(vim.api.nvim_get_current_line(), [[\]]) and "$xJ" or "J"
        end, { expr = true, desc = "Remove trailing backslash when joining lines." })
    end,
})
