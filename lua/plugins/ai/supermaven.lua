return {
    "supermaven-inc/supermaven-nvim",
    cmd = {
        "SupermavenUseFree",
        "SupermavenUsePro",
    },
    config = function(_, opts)
        --
        ev.on_load("blink.cmp", function()
            vim.schedule(function()
                require("supermaven-nvim").setup(opts)
            end)
        end)
    end,
    opts = {
        keymaps = {
            -- Handled by blink
            accept_suggestion = nil,
        },
        disable_inline_completion = true,
        ignore_filetypes = defaults.ignored.file_types,
    },
}
