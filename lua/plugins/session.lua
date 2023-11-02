return {
    "olimorris/persisted.nvim",
    event = "BufReadPre",
    config = function(_, opts)
        require("persisted").setup(opts)

        -- Persisted has a conditional that prevents auto-starting if vim.fn.argc() is not 0.
        require("persisted").start()
    end,
    init = function()
        local group = vim.api.nvim_create_augroup("PersistedHooks", {})

        vim.api.nvim_create_autocmd({ "User" }, {
            pattern = "PersistedSavePre",
            group = group,
            callback = function()
                vim.opt.guicursor = ""

                -- Arguments are always persisted in a session and can't be removed using 'sessionoptions'
                -- so remove them when saving a session
                vim.cmd("%argdelete")
            end,
        })
    end,
    keys = {
        {
            "<leader>fp",
            function()
                require("telescope").extensions.persisted.persisted()
            end,
            { desc = "Persisted Sessions" },
        },
    },
    opts = {
        ignored_dirs = {
            "~/.cache",
            "~/.cargo",
            "~/.local/state",
            "~/.rustup",
            vim.env.HOME,
            vim.fn.stdpath("data"),
            vim.fn.stdpath("state"),
        },
        save_dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
        silent = true,
        use_git_branch = true,
        should_autosave = function()
            return not vim.tbl_contains(require("config.defaults").ignored.file_types, vim.bo.filetype)
        end,
    },
    priority = 100, -- Load before alpha.nvim
}
