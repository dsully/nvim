---@type zpack.Spec[]
return {
    "coder/claudecode.nvim",
    cmd = {
        "ClaudeCode",
        "ClaudeCodeFocus",
        "ClaudeCodeSelectModel",
        "ClaudeCodeAdd",
        "ClaudeCodeSend",
        "ClaudeCodeTreeAdd",
        "ClaudeCodeStatus",
        "ClaudeCodeStart",
        "ClaudeCodeStop",
        "ClaudeCodeOpen",
        "ClaudeCodeClose",
        "ClaudeCodeDiffAccept",
        "ClaudeCodeDiffDeny",
        "ClaudeCodeCloseAllDiffs",
    },
    config = true,
    keys = {
        { "<leader>cc", nil, desc = "Claude Code", icon = "" },
        { "<leader>cco", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
        { "<leader>ccS", "<cmd>ClaudeCodeStatus<cr>", desc = "Claude Status" },
        { "<leader>ccf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
        { "<leader>ccr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
        { "<leader>ccC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
        { "<leader>ccm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude Model" },
        { "<leader>ccb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add Buffer to Claude" },
        { "<leader>ccs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
        -- { "<leader>ccs", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Add File to Claude", ft = { "minifiles", "netrw" } },
        { "<leader>cca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Diff" },
        { "<leader>ccd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject Diff" },
    },
    opts = {
        terminal_cmd = vim.env.XDG_STATE_HOME .. "/nix/profile/bin/claude"
    },
}
