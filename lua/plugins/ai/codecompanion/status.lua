local M = {
    ---@type boolean
    processing = false,
    spinner_index = 1,
}

local symbols = {
    "⠋",
    "⠙",
    "⠹",
    "⠸",
    "⠼",
    "⠴",
    "⠦",
    "⠧",
    "⠇",
    "⠏",
}

local symbols_len = #symbols

---Return true if CodeCompanion is open.
function M:open()
    return self.processing or vim.bo.filetype == "codecompanion"
end

function M:update()
    if self.processing then
        self.spinner_index = (self.spinner_index % symbols_len) + 1

        return symbols[self.spinner_index]
    else
        return ""
    end
end

return M
