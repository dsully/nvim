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

    ---@diagnostic disable-next-line: missing-fields
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

---@param filetype string
---@param subdirectory string?
M.symlink_queries = function(filetype, subdirectory)
    --
    local src = vim.fs.joinpath(tostring(vim.fn.stdpath("data")), "lazy", "tree-sitter-" .. filetype, "queries")
    local dst = vim.fs.joinpath(tostring(vim.fn.stdpath("config")), "queries", subdirectory or filetype)

    if subdirectory then
        src = vim.fs.joinpath(src, subdirectory)
    end

    local src_stat = vim.uv.fs_stat(src)
    local dst_stat = vim.uv.fs_stat(dst)

    -- Check if source directory exists
    if not src_stat then
        vim.notify("Source directory does not exist: " .. src, vim.log.levels.ERROR)
        return
    end

    if dst_stat and src_stat.ino == dst_stat.ino then
        return
    end

    vim.uv.fs_unlink(dst)

    local success, err = vim.uv.fs_symlink(src, dst)

    if not success then
        vim.notify("Failed to create symlink: " .. err, vim.log.levels.ERROR)
    end
end

return M
