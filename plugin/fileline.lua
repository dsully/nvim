-- Open files at a specific line and column.
--
-- Trailing colon, i.e. ':lnum[:colnum[:]]'
local pattern = "^([^:]+):(%d*:?%d*):?$"

--- Parse the buffer name and set the line and column.
---
---@return string
local jump = function()
    --
    local bufname = vim.api.nvim_buf_get_name(0)
    local filename, capture = bufname:match(pattern)

    if filename and capture and vim.uv.fs_access(filename, "R") then
        local pos = vim.tbl_map(tonumber, vim.split(capture, ":", { trimempty = true }))

        local current_buf = vim.api.nvim_get_current_buf()

        -- Open the file while keeping the alternate file unchanged
        vim.cmd.edit({ vim.fn.fnameescape(filename), mods = { keepalt = true } })

        -- If the file was opened with '/path/to/filename:' we won't have a position.
        local line = math.min(math.max(1, pos[1]), vim.api.nvim_buf_line_count(0))
        local column = pos[2] and pos[2] - 1 or 0

        -- Go to the specified line and column
        vim.api.nvim_win_set_cursor(0, { line, column })

        -- Center the screen on the cursor
        vim.cmd.normal({ "zz", bang = true })

        -- Close the original buffer to prevent extra buffers
        if current_buf ~= vim.api.nvim_get_current_buf() then
            vim.api.nvim_buf_delete(current_buf, { force = true })
        end

        vim.cmd.filetype("detect")

        return filename
    end

    return bufname
end

do
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            if vim.fn.argc() > 0 then
                local original = vim.fn.argidx()

                ---@diagnostic disable-next-line: param-type-mismatch
                for _, arg in ipairs(vim.fn.argv()) do
                    --
                    pcall(vim.cmd.edit, { vim.fn.fnameescape(arg), mods = { keepalt = true } })

                    local filename = jump()

                    local argidx = vim.fn.argidx()

                    vim.cmd.argdelete({ range = { argidx + 1 } })
                    vim.cmd.argadd({ args = { vim.fn.fnameescape(filename) }, range = { argidx } })
                end

                -- Return to the original argument
                vim.cmd.argument({ range = { original + 1 } })

                -- Manually call autocommands, ignored by `:argdo`
                vim.cmd.doautocmd("Syntax")
                vim.cmd.doautocmd("FileType")
            end
        end,
        nested = true,
    })
end
