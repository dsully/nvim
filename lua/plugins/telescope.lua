local M = {}

vim.b._use_git_root = false

M.cwd = function()
    if vim.b._use_git_root and not vim.b._telescope_cwd then
        --
        local paths = vim.fs.find(".git", {
            limit = 1,
            path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
            stop = vim.uv.os_homedir(),
            type = "directory",
            upward = true,
        })

        if #paths > 0 then
            vim.b._telescope_cwd = paths[1]
        end
    end

    -- Fallback to LSP or marker files.
    if not vim.b._telescope_cwd then
        vim.b._telescope_cwd = require("plugins.lsp.common").find_root()
    end

    return vim.b._telescope_cwd
end

M.args = function()
    local cwd = vim.b._telescope_cwd and vim.b._telescope_cwd or M.cwd()

    return { cwd = cwd, results_title = "cwd: " .. cwd }
end

return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        config = function()
            local actions = require("telescope.actions")
            local telescope = require("telescope")

            local function dropdown(opts)
                return require("telescope.themes").get_dropdown(opts)
            end

            telescope.setup({
                defaults = dropdown({
                    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    color_devicons = true,
                    file_ignore_patterns = {
                        "%.DS_Store",
                        "%.jpeg",
                        "%.jpg",
                        "%.lock",
                        "%.png",
                        "%.yarn/.*",
                        "^.direnv/.*",
                        "^.git/",
                        "^.venv/.*",
                        "^__pypackages__/.*",
                        "^lazy-lock.json",
                        "^site-packages/",
                        "^target/",
                        "^venv/.*",
                        "node%_modules/.*",
                    },
                    history = {
                        path = vim.fn.stdpath("data") .. "/databases/telescope_history.sqlite3",
                        limit = 100,
                    },
                    layout_config = {
                        width = 0.75,
                        prompt_position = "bottom",
                    },
                    mappings = {
                        i = {
                            ["<Esc>"] = actions.close,
                            ["<Tab>"] = actions.move_selection_next,
                            ["<C-c>"] = function()
                                vim.cmd.stopinsert({ bang = true })
                            end,
                            ["<C-k>"] = actions.cycle_history_next,
                            ["<C-j>"] = actions.cycle_history_prev,
                            ["<C-w>"] = actions.send_selected_to_qflist,
                            ["<C-q>"] = actions.send_to_qflist,
                        },
                        n = {
                            ["<C-w>"] = actions.send_selected_to_qflist,
                        },
                    },
                    path_display = { "smart" },
                    prompt_prefix = " ❯ ",
                    scroll_strategy = "cycle",
                }),
                extensions = {
                    file_browser = {
                        hidden = true,
                        hijack_netrw = true,
                        initial_mode = "normal",
                        prompt_prefix = "    ",
                    },
                },
                pickers = {
                    buffers = {
                        ignore_current_buffer = true,
                        mappings = {
                            i = { ["<C-x>"] = "delete_buffer" },
                            n = { ["<C-x>"] = "delete_buffer" },
                        },
                        previewer = false,
                        prompt_prefix = " 󰀿  ",
                        show_all_buffers = true,
                        sort_lastused = true,
                        sort_mru = true,
                    },
                    find_files = {
                        find_command = { "fd", "--type", "f", "--color", "never", "--strip-cwd-prefix" },
                        sorting_strategy = "ascending",
                        hidden = true,
                        prompt_prefix = "   ",
                    },
                    git_files = {
                        additional_args = function()
                            return { "--hidden" }
                        end,
                        glob_pattern = { "!.git" },
                        hidden = true,
                        prompt_prefix = "   ",
                        show_untracked = true,
                    },
                    live_grep = {
                        glob_pattern = { "!.git" },
                        find_command = { "rg", "--color", "never", "--hidden", "--no-require-git", "--sort", "--trim" },
                        prompt_prefix = "   ",
                    },
                    oldfiles = {
                        only_cwd = true,
                        prompt_prefix = " 󰋚  ",
                        file_ignore_patterns = {
                            ".git/COMMIT_EDITMSG",
                        },
                    },
                },
            })

            telescope.load_extension("smart_history")
            telescope.load_extension("ui-select")
            telescope.load_extension("zf-native")
        end,
        init = function()
            for _, map in pairs({
                { key = "B", cmd = "buffers", desc = "Buffers" },
                { key = "c", cmd = "git_commits", desc = "Git Commits" },
                { key = "g", cmd = "live_grep", desc = "Live Grep" },
                { key = "i", cmd = "symbols", desc = "Icons / Symbols" },
                { key = "o", cmd = "oldfiles", desc = "Recently Opened" },
                { key = "r", cmd = "resume", desc = "Resume Last Telescope Finder" },
                { key = "w", cmd = "grep_string", desc = "Words" },
            }) do
                vim.keymap.set("n", "<leader>f" .. map.key, function()
                    require("telescope.builtin")[map.cmd](M.args())
                end, { desc = map.desc })
            end
        end,
        dependencies = {
            { "natecraddock/telescope-zf-native.nvim" },
            { "nvim-telescope/telescope-smart-history.nvim", dependencies = { "kkharji/sqlite.lua" } },
            { "nvim-telescope/telescope-symbols.nvim" },
            { "nvim-telescope/telescope-ui-select.nvim" },
        },
        keys = {
            {
                -- Use git_files if we're at the top of a git repo. Otherwise find_files.
                "<leader>ff",
                function()
                    local builtin = vim.g.gitsigns_head and "git_files" or "find_files"

                    require("telescope.builtin")[builtin](M.args())
                end,
                { desc = "Find Files" },
            },
            {
                "<leader>ftr",
                function()
                    vim.b._use_git_root = not vim.b._use_git_root

                    vim.notify(string.format("Telescope root is now: %s", M.cwd()))
                end,
                {
                    desc = "Telescope: Toggle root between Git and LSP/current directory.",
                },
            },
            {
                "z=",
                function()
                    vim.cmd.Telescope("spell_suggest")
                end,
                { desc = "Suggest Spelling" },
            },
        },
    },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        keys = {
            {
                "<leader>fb",
                function()
                    require("telescope").extensions.file_browser.file_browser(M.args())
                end,
                { desc = "File Browser" },
            },
        },
    },
    {
        "benfowler/telescope-luasnip.nvim",
        keys = {
            {
                "<leader>fs",
                function()
                    require("telescope").extensions.luasnip.luasnip()
                end,
                { desc = "Snippets" },
            },
        },
    },
    {
        "syphar/python-docs.nvim",
        keys = {
            {
                "<leader>fd",
                function()
                    require("telescope").extensions.python_docs.python_docs()
                end,
                { desc = "Docs" },
            },
        },
    },
    {
        "tsakirist/telescope-lazy.nvim",
        keys = {
            {
                "<leader>fl",
                function()
                    require("telescope").extensions.lazy.lazy()
                end,
                { desc = "Lazy Packages" },
            },
        },
    },
    {
        "2kabhishek/nerdy.nvim",
        cmd = "Nerdy",
        keys = {
            {
                "<leader>fl",
                function()
                    -- Ensure that telescope-ui-select is loaded.
                    require("telescope")
                    require("nerdy").list()
                end,
                { desc = "Nerd Icons" },
            },
        },
    },
}
