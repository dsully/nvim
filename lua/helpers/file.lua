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
    } --[[@as snacks.input.Opts]], function(newfile)
        if not newfile or newfile == "" or newfile == file:sub(#root + 2) then
            return
        end

        vim.cmd.edit(vim.fs.normalize(newfile))
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

---Read the content of a TOML file.
---@param path string
---@return table
M.read_toml = function(path)
    --
    -- This comes from vhyrro/luarocks.nvim / the toml-edit rock.
    local toml = require("toml_edit")
    local parsed = toml.parse(M.read(path))

    if not parsed then
        notify.error("Couldn't read " .. path)
        return {}
    end

    return parsed
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

---Return true if the current working directory is in my local source directory.
---@return boolean
M.is_local_dev = function()
    local cwd = tostring(vim.uv.cwd())

    for _, path in ipairs({
        vim.env.XDG_CONFIG_HOME,
        vim.env.XDG_DATA_HOME .. "/chezmoi",
        vim.fs.joinpath(vim.env.HOME, "dev", "home"),
    }) do
        if vim.startswith(cwd, path) then
            return true
        end
    end

    return false
end

---@return string?
M.git_root = function()
    local obj = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()

    if obj.code ~= 0 then
        notify.error("Not in a Git repository!", { icon = "󰏋" })
        return
    end

    return vim.trim(obj.stdout or "")
end

--- Return true if the current working directory is in a Git repository and has at least 1 commit.
---@return boolean
M.is_git = function()
    return vim.system({ "git", "rev-parse", "HEAD" }, { stderr = false, stdout = false } --[[@as vim.SystemOpts]]):wait().code == 0
end

--- Escape special pattern matching characters in a string
---@param input string
---@return string
M.escape_pattern = function(input)
    local magic_chars = { "%", "(", ")", ".", "+", "-", "*", "?", "[", "^", "$" }

    for _, char in ipairs(magic_chars) do
        input = input:gsub("%" .. char, "%%" .. char)
    end

    return input
end

-- Return a normalized filename, with characters escaped.
---@param input string
---@return string
M.normalize = function(input)
    return vim.fs.normalize(vim.fn.fnameescape(input))
end

-- Return the current filename.
---@param bufnr integer
---@return string
M.filename = function(bufnr)
    return M.normalize(vim.api.nvim_buf_get_name(bufnr or 0))
end

---@param filetype string
---@param subdirectory string?
M.symlink_queries = function(filetype, subdirectory)
    --
    local src = vim.fs.joinpath(require("lazy.core.config").options.root, "tree-sitter-" .. filetype, "queries")
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

---Create a combined file type for template languages.
---@param filename string
---@param extension string The extension to strip from the filename for detection.
---@param combined string The combined file type. eg: "jinja"
---@return string?
M.template_type = function(filename, extension, combined)
    --
    -- Remove the chezmoi 'dot_' if it exists.
    filename = tostring(filename:gsub("." .. extension, ""):gsub("dot_", "."))

    -- Attempt with buffer content and filename
    --- @type string?
    local filetype = vim.filetype.match({ filename = filename }) or ""

    if not filetype then
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        for index, line in ipairs(lines) do
            if string.match(line, "{{") then
                table.remove(lines, index) -- remove template lines
            end
        end

        if not filetype then
            filetype = vim.filetype.match({ filename = filename, contents = lines }) -- attempt without template lines

            if not filetype then
                filetype = vim.filetype.match({ contents = lines }) -- attempt without filename
            end
        end
    end

    if filetype then
        return filetype .. "." .. combined
    end
end

return M
