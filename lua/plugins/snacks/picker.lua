local M = {}

---@param str string
---@return string
local function cap(str)
    return str:sub(1, 1):upper() .. str:sub(2):lower()
end

---@param name string
---@param level? snacks.notifier.level
---@return string
local function hl(name, level)
    return "SnacksNotifier" .. name .. (level and cap(level) or "")
end

M.notifications = function()
    ---@type snacks.picker.Config
    return Snacks.picker({
        confirm = { "copy", "close" },
        format = function(item)
            --
            return {
                { item.date, hl("HistoryDateTime") },
                { " ", virtual = true },
                { item.icon, hl("Icon", item.level) },
                { " ", virtual = true },
                { item.text, "Normal" },
            }
        end,
        items = vim.iter(Snacks.notifier.get_history({ reverse = true }))
            :map(function(entry)
                --
                return {
                    date = tostring(os.date("%R", entry.added)),
                    icon = entry.icon,
                    idx = entry.id,
                    level = entry.level,
                    preview = {
                        text = entry.msg,
                        ft = entry.ft or "markdown",
                    },
                    text = entry.title or vim.split(entry.msg, "\n", { plain = true })[1],
                    -- score = entry.id,
                }
            end)
            :totable(),
        preview = Snacks.picker.preview.preview,
    })
end

-- Grep the current buffer for the cword.
-- Match on partial words.
M.grep_curbuf_cword = function()
    --
    -- Use the builtin grep_buffers source
    Snacks.picker.pick({
        source = "grep_buffers",
        search = vim.fn.expand("<cword>"),
        live = false,
        buffers = false,
        -- A bit of a hack, but it works to search only the current file.
        dirs = {
            vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()),
        },
    })
end

---@type LazySpec
return {
    "folke/snacks.nvim",
    keys = {
        {
            "<leader>ff",
            function()
                local sort = { fields = { "file" } }

                if Snacks.git.get_root() then
                    Snacks.picker.git_files({ sort = sort, untracked = true })
                else
                    Snacks.picker.files({ filter = { cwd = true }, sort = sort })
                end
            end,
            desc = "Files",
        },

        -- stylua: ignore start
        ---@diagnostic disable: undefined-field
        { "<leader>f/", function() M.grep_curbuf_cword() end, desc = "Current Buffer <cword>" },
        { "<leader>f;", function() Snacks.picker.resume() end, desc = "Resume Picker" },
        { "<leader>fC", function() Snacks.picker.git_log({ current_file = true }) end, desc = "Commits" },
        { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
        { "<leader>fc", function() Snacks.picker.git_log() end, desc = "Commits" },
        { "<leader>fd", function() Snacks.picker.diagnostics({ format = "file" }) end, desc = "Diagnostics" },
        { "<leader>fe", function() Snacks.picker.icons({ icon_sources = { "emoji" }}) end, desc = "Emoji" },
        { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
        { "<leader>fh", function() Snacks.picker.highlights() end, desc = "Highlights" },
        { "<leader>fi", function() Snacks.picker.icons({ icon_sources = { "nerd_fonts" }}) end, desc = "Nerd Icons" },
        { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
        { "<leader>fl", function() Snacks.picker.lazy() end, desc = "Lazy Plugins" },
        { "<leader>fn", function() M.notifications() end, desc = "Notifications" },
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
                    -- local root = LazyVim.root({ buf = p.input.filter.current_buf, normalize = true })
                    -- local root = require("helpers.lsp").find_root(p.input.filter.current_buf)
                    local root = nvim.root.get({ buf = p.input.filter.current_buf, normalize = true })
                    local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
                    local current = p:cwd()
                    p:set_cwd(current == root and cwd or root)
                    p:find()
                end,
            },
            enabled = true,
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
            ---@class snacks.picker.matcher.Config
            matcher = {
                fuzzy = false,
            },
            prompt = " ",
            win = {
                input = {
                    keys = {
                        ["<C-c>"] = { "close", mode = { "i", "n" } },
                        ["<C-h>"] = { "toggle_hidden", mode = { "i", "n" } },
                        ["<C-t>"] = { "toggle_cwd", mode = { "n", "i" } },
                    },
                },
            },
            ui_select = true,
        },
    },
}
