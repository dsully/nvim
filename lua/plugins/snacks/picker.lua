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

---@type snacks.picker.Config
M.opts = {
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
                ["<C-h>"] = { "toggle_hidden", mode = { "i", "n" } },
                ["<C-c>"] = { "close", mode = { "i", "n" } },
                ["<Esc>"] = { "close", mode = { "i", "n" } },
            },
        },
    },
    ui_select = true,
}

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

return M
