local M = {}

function M.open(lines)
    local popup = require("nui.popup")({
        border = {
            style = vim.g.border,
        },
        buf_options = {
            filetype = "markdown",
        },
        enter = true,
        focusable = true,
        position = "50%",
        size = {
            width = "80%",
            height = "80%",
        },
        win_options = {
            winhighlight = "Normal:Normal,FloatBorder:Normal",
        },
    })

    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)

    local close = function()
        popup:unmount()
    end

    popup:on("BufLeave", close)
    popup:map("n", "q", close, { silent = true })
    popup:map("n", "<esc>", close, { silent = true })

    popup:mount()
end

return M
