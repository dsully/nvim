local M = {}

local realpath = function(path)
    return (vim.uv.fs_realpath(path) or path)
end

---Edit a new file relative to the same directory as the current buffer
function M.edit()
    local buf = vim.api.nvim_get_current_buf()
    local file = realpath(vim.api.nvim_buf_get_name(buf))
    local root = assert(realpath(vim.uv.cwd() or "."))

    if file:find(root, 1, true) ~= 1 then
        root = vim.fs.dirname(file)
    end

    vim.ui.input({
        prompt = "File Name: ",
        default = vim.fs.joinpath(root, ""),
        completion = "file",
    }, function(newfile)
        if not newfile or newfile == "" or newfile == file:sub(#root + 2) then
            return
        end

        vim.cmd.edit(vim.fs.normalize(vim.fs.joinpath(root, newfile)))
    end)
end

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

return M
