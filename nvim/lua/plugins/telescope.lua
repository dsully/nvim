return {
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
                    find_command = { "fd", "--type", "f", "--color", "never", "--no-require-git", "--strip-cwd-prefix" },
                    sorting_strategy = "ascending",
                    hidden = false,
                    prompt_prefix = "   ",
                },
                git_files = {
                    hidden = true,
                    prompt_prefix = "   ",
                    show_untracked = true,
                },
                live_grep = {
                    find_command = { "rg", "--color", "never", "--no-require-git", "--sort", "--trim" },
                    prompt_prefix = "   ",
                },
                oldfiles = {
                    only_cwd = true,
                    prompt_prefix = " 󰋚  ",
                },
            },
        })

        telescope.load_extension("file_browser")
        telescope.load_extension("lazy")
        telescope.load_extension("luasnip")
        telescope.load_extension("noice")
        telescope.load_extension("notify")
        telescope.load_extension("smart_history")
        telescope.load_extension("zf-native")
    end,
    init = function()
        local use_git_root = false

        local function root()
            if use_git_root then
                return vim.trim(vim.system({ "git", "rev-parse", "--show-toplevel" }, { cwd = vim.uv.cwd() }):wait().stdout)
            end

            return require("plugins.lsp.common").find_root()
        end

        vim.keymap.set("n", "<leader>tr", function()
            use_git_root = not use_git_root

            vim.notify(string.format("Telescope root is now: %s", root()))
        end, {
            desc = "Telescope: Toggle root between Git and LSP/current directory.",
        })

        for _, map in pairs({
            { key = "B", cmd = "buffers", desc = "Buffers" },
            { key = "N", cmd = "noice", desc = "Noice" },
            { key = "l", cmd = "lazy", desc = "Lazy Plugins" },
            { key = "n", cmd = "notify", desc = "Notifications" },
            { key = "o", cmd = "oldfiles", desc = "Recently Opened" },
            { key = "r", cmd = "resume", desc = "Resume Last Telescope Finder" },
            { key = "s", cmd = "luasnip", desc = "Snippets" },
        }) do
            vim.keymap.set("n", "<leader>f" .. map.key, function()
                vim.cmd.Telescope(map.cmd)
            end, { desc = map.desc })
        end

        for _, map in pairs({
            { key = "c", cmd = "git_commits", desc = "Git Commits" },
            { key = "g", cmd = "live_grep", desc = "Live Grep" },
            { key = "w", cmd = "grep_string", desc = "Words" },
        }) do
            vim.keymap.set("n", "<leader>f" .. map.key, function()
                local cwd = root()

                require("telescope.builtin")[map.cmd]({ cwd = cwd, results_title = "root: " .. cwd })
            end, { desc = map.desc })
        end

        -- Use git_files if we're at the top of a git repo. Otherwise find_files.
        vim.keymap.set("n", "<leader>ff", function()
            local cwd = root()
            local builtin = vim.uv.fs_stat(cwd .. "/.git") and "git_files" or "find_files"

            require("telescope.builtin")[builtin]({ cwd = cwd, results_title = "root: " .. cwd })
        end, { desc = "Find Files" })

        vim.keymap.set("n", "<leader>fb", function()
            local cwd = root()

            require("telescope").extensions.file_browser.file_browser({ cwd_to_path = true, path = cwd, results_title = "root: " .. cwd })
        end, { desc = "File Browser" })

        vim.keymap.set("n", "<leader>ft", vim.cmd.TodoTelescope, { desc = "TODOs" })

        vim.keymap.set("n", "z=", function()
            vim.cmd.Telescope("spell_suggest")
        end, { desc = "Suggest Spelling" })
    end,
    dependencies = {
        { "benfowler/telescope-luasnip.nvim" },
        { "natecraddock/telescope-zf-native.nvim" },
        { "nvim-telescope/telescope-file-browser.nvim" },
        { "nvim-telescope/telescope-smart-history.nvim", dependencies = { "kkharji/sqlite.lua" } },
        { "tsakirist/telescope-lazy.nvim" },
        { "folke/noice.nvim" },
    },
}
