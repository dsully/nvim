local M = {}

---@class FloatOptions
---@field lines string[]
---@field filetype string
---@field window WindowOptions?
---@field relative string?
---@field callback ?function(buf: integer)

---@class WindowOptions
---@field anchor string?
---@field width number?
---@field height number?

---@class WindowPosition
---@field row number
---@field col number

---@class WindowSize
---@field height number
---@field width number

---@param options WindowOptions?
---@return table<WindowPosition, WindowSize>
M.window = function(options)
    options = options or {}

    local editor_width = vim.o.columns
    local editor_height = vim.o.lines

    local window_width = options.width or 80
    local window_height = options.height or 0.9

    -- Handle incoming percentages
    window_width = window_width < 1 and math.floor(editor_width * window_width) or window_width
    window_height = window_height < 1 and math.floor(editor_height * window_height) or window_height

    local size = {
        width = math.min(window_width, editor_width),
        height = math.min(window_height, editor_height - 2), -- `-2` for status and command lines
    }

    local position = {
        col = math.floor((editor_width - size.width) / 2),
        row = math.floor((editor_height - size.height) / 2) - 1, -- `-1` offset to always have status/command lines visible
    }

    local anchor = options.anchor and string.upper(options.anchor) or ""

    if string.match(anchor, "[NS]") then
        position.row = string.match(anchor, "N") and 0 or editor_height - size.width - 2
    end

    if string.match(anchor, "[WE]") then
        position.col = string.match(anchor, "W") and 0 or editor_width - size.width
    end

    return { position, size }
end

---@param options FloatOptions
function M.open(options)
    local position, size = unpack(M.window(options.window))

    local popup = require("nui.popup")({
        border = {
            style = vim.g.border,
        },
        buf_options = {
            filetype = options.filetype,
            modifiable = false,
            readonly = true,
        },
        enter = true,
        focusable = true,
        position = position,
        relative = options.relative or "editor",
        size = size,
        win_options = {
            -- keep cursor at the center
            scrolloff = 999,
            winhighlight = "Normal:Normal,FloatBorder:Normal",
        },
    })

    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, options.lines)

    local close = function()
        popup:unmount()
    end

    popup:on(require("helpers.event").BufLeave, close)
    popup:map("n", "q", close, { silent = true })
    popup:map("n", "<esc>", close, { silent = true })

    popup:mount()

    if options.callback then
        options.callback(popup.bufnr)
    end
end

return M
