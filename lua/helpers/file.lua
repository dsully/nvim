local M = {}

---Read the content of a file.
---@param path string
---@return string?
M.read = function(path)
    local fd = vim.uv.fs_open(path, "r", 438)
    local content

    if fd then
        local stat = vim.uv.fs_fstat(fd)

        if stat then
            content = vim.uv.fs_read(fd, stat.size, 0)
        end

        vim.uv.fs_close(fd)
    end

    return content
end

---Write data to a file.
---@param path string
---@param data string|string[]
M.write = function(path, data)
    local fd = vim.uv.fs_open(path, "w", 438)

    if fd then
        vim.uv.fs_write(fd, data, 0)
        vim.uv.fs_close(fd)
    end
end

--- Whether buf is big (`uv.fs_stat` only works for file)
---@param bufnr? integer
---@return boolean
function M.is_large_file(bufnr)
    bufnr = bufnr or 0
    return vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr)) > vim.g.large_file_bytes
end

return M
