-- Show unix epoch seconds (optionally with a fractional part) as local time ghost text.
local ns = vim.api.nvim_create_namespace("epoch")

---@param int string
---@param frac string
---@return string?
local format = function(int, frac)
    if #int ~= 10 then
        return nil
    end

    local text = os.date("%Y-%m-%d %H:%M:%S", tonumber(int)) --[[@as string]]
    local digits = frac:sub(2)

    if digits ~= "" then
        text = text .. "." .. (digits .. "000000"):sub(1, 6)
    end

    return text
end

vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, _, buf)
        return vim.bo[buf].buftype == ""
    end,

    on_line = function(_, _, buf, row)
        local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""

        for int, frac in line:gmatch("%f[%w](%d+)(%.?%d*)%f[%W]") do
            local text = format(int, frac)

            if text then
                vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
                    virt_text = { { text, "Comment" } },
                    virt_text_pos = "eol",
                    ephemeral = true,
                })
            end
        end
    end,
})
