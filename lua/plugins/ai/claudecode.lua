---@type LazySpec
return {
    "coder/claudecode.nvim",
    event = ev.VeryLazy,
    keys = {
        { "<leader>A", nil, desc = "AI/Claude Code" },
        { "<leader>Ac", vim.cmd.ClaudeCode, desc = "Toggle Claude" },
        { "<leader>Af", vim.cmd.ClaudeCodeFocus, desc = "Focus Claude" },
        { "<leader>Ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
        { "<leader>AC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
        { "<leader>Am", vim.cmd.ClaudeCodeSelectModel, desc = "Select Claude model" },
        { "<leader>Ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
        { "<leader>As", vim.cmd.ClaudeCodeSend, mode = "v", desc = "Send to Claude" },
        -- Diff management
        { "<leader>Aa", vim.cmd.ClaudeCodeDiffAccept, desc = "Accept diff" },
        { "<leader>Ad", vim.cmd.ClaudeCodeDiffDeny, desc = "Deny diff" },
    },
    opts = {
        terminal = {
            auto_close = true,
            split_side = "right",
            split_width_percentage = 0.5,
        },
    },
}
