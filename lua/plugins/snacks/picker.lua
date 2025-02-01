---@type LazySpec
return {
    "folke/snacks.nvim",
    keys = {
        --stylua: ignore start
        ---@diagnostic disable: undefined-field
        { "<leader>f/", function() Snacks.picker.grep_word({ dirs = { nvim.file.filename() } }) end, desc = "Buffer Word" },
        { "<leader>f;", function() Snacks.picker.resume() end, desc = "Resume Picker" },
        { "<leader>fB", function() Snacks.picker.buffers() end, desc = "Buffers" },
        { "<leader>fC", function() Snacks.picker.git_log({ current_file = true }) end, desc = "Commits" },
        { "<leader>fb", function() Snacks.picker.explorer() end, desc = "Browse" },
        { "<leader>fc", function() Snacks.picker.git_log() end, desc = "Commits" },
        { "<leader>fd", function() Snacks.picker.diagnostics({ format = "file" }) end, desc = "Diagnostics" },
        { "<leader>fe", function() Snacks.picker.icons({ icon_sources = { "emoji" }}) end, desc = "Emoji" },
        { "<leader>ff", function() Snacks.picker.smart({ multi = { "git_files", "files" } }) end, desc = "Files", },
        { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
        { "<leader>fh", function() Snacks.picker.highlights() end, desc = "Highlights" },
        { "<leader>fi", function() Snacks.picker.icons({ icon_sources = { "nerd_fonts" }}) end, desc = "Nerd Icons" },
        { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
        { "<leader>fl", function() Snacks.picker.lazy() end, desc = "Lazy Plugins" },
        { "<leader>fn", function() Snacks.picker.notifications({ confirm = { "copy" } }) end, desc = "Notifications" },
        { "<leader>fo", function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "Recently Opened" },
        { "<leader>fq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
        { "<leader>fs", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Symbols" },
        { "<leader>fu", function() Snacks.picker.undo() end, desc = "Undo Tree" },
        { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Words" },
    },
    ---@type snacks.picker.Config
    opts = {
        picker = {
            actions = {
                ---@param p snacks.Picker
                toggle_cwd = function(p)
                    local root = nvim.root.get({ buf = p.input.filter.current_buf, normalize = true })
                    local cwd = vim.fs.normalize(vim.uv.cwd() or ".")
                    local current = p:cwd()

                    p:set_cwd(current == root and cwd or root)
                    p:find()
                end,
            },
            enabled = true,
            formatters = {
                file = {
                    truncate = 160,
                },
            },
            ---@class snacks.picker.icons
            icons = {
                kinds = defaults.icons.lsp,
            },
            layout = {
                layout = {
                    backdrop = false,
                    border = defaults.ui.border.name,
                    height = 0.85,
                    width = 0.85,
                    title = "{source} {live}",
                    title_pos = "center",
                    box = "vertical",
                    {
                        border = defaults.ui.border.name,
                        height = 0.5,
                        win = "preview",
                    },
                    {
                        border = "none",
                        win = "list",
                    },
                    {
                        border = "top",
                        height = 1,
                        win = "input",
                    },
                },
                reverse = false,
            },
            ---@class snacks.picker.sources.Config
            sources = {
                files = {
                    filter = {
                        cwd = true,
                    },
                    limit = 10,
                },
                git_files = {
                    untracked = true,
                },
            },
            win = {
                input = {
                    keys = {
                        ["<C-c>"] = { "close", mode = { "i", "n" } },
                        ["<C-h>"] = { "toggle_hidden", mode = { "i", "n" } },
                        ["<C-t>"] = { "toggle_cwd", mode = { "n", "i" } },
                    },
                },
            },
        },
    },
}
