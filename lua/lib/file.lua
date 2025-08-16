local M = {}

---@param path string
---@return string
function M.realpath(path)
    return (vim.uv.fs_realpath(path) or path)
end

---Return the XDG cache path to a file.
---@param path string
---@return string
function M.xdg_cache(path)
    return vim.fs.joinpath(vim.env.XDG_CACHE_HOME or vim.fs.abspath("~/.cache"), path)
end

---Return the XDG config path to a file.
---@param path string
---@return string
function M.xdg_config(path)
    return vim.fs.joinpath(vim.env.XDG_CONFIG_HOME or vim.fs.abspath("~/.config"), path)
end

---@return string
function M.cwd()
    return M.realpath(vim.uv.cwd() or ".")
end

---Edit a new file relative to the same directory as the current buffer
function M.edit()
    local buf = vim.api.nvim_get_current_buf()
    local file = M.filename(buf)

    ---@diagnostic disable-next-line: param-type-not-match
    vim.ui.input({
        prompt = "File Name: ",
        default = vim.fs.dirname(file),
        completion = "file",
    }, function(newfile)
        if not newfile or newfile == "" then
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
        Snacks.notify.error("Couldn't read " .. path)
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
    local cwd = M.cwd()

    for _, path in ipairs({
        vim.env.XDG_CONFIG_HOME,
        vim.env.XDG_DATA_HOME .. "/chezmoi",
        vim.fs.abspath("~/dev/home"),
    }) do
        if vim.startswith(cwd, path) then
            return true
        end
    end

    return false
end

--- Return the git root if it exists.
---
---@param quiet boolean?
---@return string?
M.git_root = function(quiet)
    local obj = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()

    if obj.code ~= 0 and not quiet then
        Snacks.notify.error("Not in a Git repository!", { icon = "󰏋" })
        return
    end

    return vim.trim(obj.stdout or "")
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
---@param bufnr integer?
---@return string
M.filename = function(bufnr)
    return M.normalize(M.realpath(vim.api.nvim_buf_get_name(bufnr or 0)))
end

-- Return the stem part of a path, ie: without any extension.
---@param path string
---@return string
M.stem = function(path)
    local filename = vim.fs.basename(path)

    local last_dot = filename:reverse():find("%.")

    return filename:sub(1, last_dot and -last_dot - 1 or #filename)
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
