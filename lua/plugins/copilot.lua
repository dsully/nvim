return {
    "zbirenbaum/copilot.lua",
    event = "VeryLazy",
    opts = {
        filetypes = {
            bash = true,
            c = true,
            cpp = true,
            fish = true,
            go = true,
            html = true,
            java = true,
            javascript = true,
            just = true,
            lua = true,
            python = true,
            rust = true,
            sh = true,
            typescript = true,
            zsh = true,
            ["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
        },
        -- Per: https://github.com/zbirenbaum/copilot-cmp#install
        panel = { enabled = false },
        suggestion = { enabled = false },
    },
}
