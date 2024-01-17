-- General diagnostics.
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "󰙨󰙨 Next Diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "󰙨󰙨 Previous Diagnostic" })
vim.keymap.set("n", "<leader>xr", vim.diagnostic.reset, { desc = " Reset" })
vim.keymap.set("n", "<leader>xs", vim.diagnostic.open_float, { desc = "󰙨 Show" })

vim.keymap.set("n", "dt", function()
    if vim.diagnostic.is_disabled() then
        vim.diagnostic.enable()
    else
        vim.diagnostic.disable()
    end
end, { noremap = true, desc = "Diagnostics Toggle" })

-- Buffers
vim.keymap.set("n", "]b", vim.cmd.bnext, { desc = " Next Buffer" })
vim.keymap.set("n", "[b", vim.cmd.bprev, { desc = " Previous Buffer" })

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

-- Copy selection to gui-clipboard
vim.keymap.set("x", "Y", '"+y', { desc = "Yank to Clipboard" })

vim.keymap.set("n", "<leader>a", "<cmd>%y<cr>", { desc = "Yank All Lines" })

-- Don't delete into the system clipboard.
vim.keymap.set({ "n", "x" }, "dw", '"_dw', { noremap = true })
vim.keymap.set({ "n", "x" }, "c", '"_c', { noremap = true })
vim.keymap.set({ "n", "x" }, "C", '"_C', { noremap = true })

-- Create/edit file within the current directory
vim.keymap.set("n", "<localleader><localleader>e", function()
    return vim.ui.input({ prompt = "Save as: " }, function(name)
        if name then
            vim.cmd.edit(("%s/%s"):format(vim.fs.dirname(vim.api.nvim_buf_get_name(0)), name))
        end
    end)
end, { silent = true, expr = false, desc = "Create/edit file relative to current document" })

-- Close floating windows [Neovim 0.10 and above]
vim.keymap.set("n", "<leader>fq", vim.cmd.fclose, { silent = true, desc = "Close all floating windows" })
