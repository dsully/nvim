local M = {}

---@param path string
M.read = function(path)
    local fd = vim.loop.fs_open(path, "r", 438)
    local content

    if fd then
        local stat = vim.loop.fs_fstat(fd)

        if stat then
            content = vim.loop.fs_read(fd, stat.size, 0)
        end

        vim.loop.fs_close(fd)
    end

    return content
end

return M
