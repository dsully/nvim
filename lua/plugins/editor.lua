local M = {}

local defaults = require("config.defaults")

vim.b._use_git_root = false

M.cwd = function()
    if vim.b._use_git_root and not vim.b._telescope_cwd then
        --
        local path = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
        local stop = vim.uv.os_homedir()

        if path and stop then
            local paths = vim.fs.find(".git", {
                limit = 1,
                path = path,
                stop = stop,
                type = "directory",
                upward = true,
            })

            if #paths > 0 then
                vim.b._telescope_cwd = paths[1]
            end
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
                    borderchars = defaults.ui.border.chars,
                    color_devicons = true,
                    file_ignore_patterns = defaults.files.ignored_patterns,
                    -- open files in the first window that is an actual file.
                    -- use the current window if no other window is available.
                    get_selection_window = function()
                        local wins = vim.api.nvim_list_wins()

                        table.insert(wins, 1, vim.api.nvim_get_current_win())

                        for _, win in ipairs(wins) do
                            local buf = vim.api.nvim_win_get_buf(win)

                            if vim.bo[buf].buftype == "" then
                                return win
                            end
                        end
                        return 0
                    end,
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
                            ["<C-q>"] = actions.send_to_qflist,

                            -- Delete word
                            ["<C-w>"] = { "<C-o>diw", type = "command" },
                        },
                        n = {
                            ["<C-w>"] = actions.send_selected_to_qflist,
                        },
                    },
                    path_display = { "truncate" },
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
                    },
                },
            })

            telescope.load_extension("zf-native")
        end,
        init = function()
            local map = require("helpers.keys").map

            for _, t in pairs({
                { key = "B", cmd = "buffers", desc = "Buffers" },
                { key = "d", cmd = "diagnostics", desc = "Diagnostics" },
                { key = "c", cmd = "git_commits", desc = "Git Commits" },
                { key = "g", cmd = "live_grep", desc = "Live Grep" },
                { key = "e", cmd = "symbols", desc = "Emojii" },
                { key = "o", cmd = "oldfiles", desc = "Recently Opened" },
                { key = "w", cmd = "grep_string", desc = "Words" },
                { key = ";", cmd = "resume", desc = "Resume Telescope" },
            }) do
                map("<leader>f" .. t.key, tscope(t.cmd, M.args), t.desc)
            end

            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.select = function(...)
                require("telescope").load_extension("ui-select")
                return vim.ui.select(...)
            end
        end,
        dependencies = {
            { "natecraddock/telescope-zf-native.nvim" },
            { "nvim-telescope/telescope-symbols.nvim" },
            { "nvim-telescope/telescope-ui-select.nvim" },
        },
        keys = {
            -- Use git_files if we're at the top of a git repo. Otherwise find_files.
            { "<leader>ff", tscope("find_files", M.args), desc = "Find Files" },
            {
                "<leader>fR",
                function()
                    vim.b._use_git_root = not vim.b._use_git_root

                    vim.notify(string.format("Telescope root is now: %s", M.cwd()))
                end,
                desc = "Telescope: Toggle root between Git and LSP/current directory.",
            },
            {
                "<leader>f/",
                tscope("live_grep", {
                    path_display = { tail = true },
                    prompt_title = "Search Buffer Content",
                    search_dirs = { vim.fn.expand("%:p") },
                }),
                "Buffer Content",
            },
            { "z=", tscope("spell_suggest"), desc = "Suggest Spelling" },
        },
    },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        keys = { { "<leader>fb", tscope("file_browser", M.args), desc = "File Browser" } },
    },
    {
        "tsakirist/telescope-lazy.nvim",
        keys = { { "<leader>fl", tscope("lazy"), desc = "Lazy Packages" } },
    },
    {
        "2kabhishek/nerdy.nvim",
        keys = { { "<leader>fi", tscope("nerdy"), desc = "Nerd Icons" } },
    },
    {
        "SmiteshP/nvim-navic",
        event = "LazyFile",
        init = function()
            vim.g.navic_silence = true
        end,
        opts = {
            highlight = true,
            lazy_update_context = true,
            lsp = {
                auto_attach = true,
                preference = { "basedpyright" },
            },
        },
    },
    {
        "folke/todo-comments.nvim",
        cmd = { "TodoTrouble", "TodoTelescope" },
        event = "LazyFile",
        -- stylua: ignore
        keys = {
            { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
            { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
            { "<leader>ft", vim.cmd.TodoTelescope, desc = "TODOs" },
        },
        opts = {
            highlight = {
                pattern = [[(KEYWORDS)\s*(\([^\)]*\))?:]],
            },
        },
    },
    {
        "folke/trouble.nvim",
        cmd = { "Trouble" },
        dependencies = "echasnovski/mini.icons",
        keys = {
            {
                "<leader>xx",
                function()
                    require("trouble").toggle({ focus = true, mode = "diagnostics" })
                end,
                desc = "Trouble",
            },
        },
        opts = {
            auto_preview = false,
            use_diagnostic_signs = true,
        },
    },
    {
        "trmckay/based.nvim",
        --stylua: ignore
        keys = {
            { "<C-b>", function() require("based").convert() end, mode = { "n", "x" }, desc = "Convert to/from hex & decimal." },
        },
    },
    {
        -- Pattern replacement UI.
        "AckslD/muren.nvim",
        cmd = "MurenToggle",
        opts = {
            patterns_width = 60,
            patterns_height = 20,
            options_width = 40,
            preview_height = 24,
        },
    },
    {
        "MagicDuck/grug-far.nvim",
        cmd = "GrugFar",
        keys = {
            {
                "<leader>sr",
                function()
                    local grug = require("grug-far")
                    local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
                    grug.grug_far({
                        transient = true,
                        prefills = {
                            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
                        },
                    })
                end,
                mode = { "n", "v" },
                desc = "Search and Replace",
            },
        },
        opts = {
            debounceMs = 500,
            engine = "astgrep",
            folding = {
                enabled = false,
            },
            headerMaxWidth = 80,
            maxWorkers = 10,
            minSearchChars = 2,
            startInInsertMode = false,
            windowCreationCommand = "split",
        },
    },
}
