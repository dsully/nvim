local M = {}

local ruff_prefixes = { "TAE", "PIE" }

local ruff_default_config = {
    enabled = true,
    select = {
        "A",
        "B",
        "E",
        "F",
        "W",
        "C4",
        "FA",
        "PT",
        "UP",
        "ARG",
        "DTZ",
        "EXE",
        "FLY",
        "ICN",
        "INP",
        "ISC",
        "PIE",
        "PYI",
        "RET",
        "RSE",
        "RUF",
        "SIM",
        "SLF",
        "TRY",
        "YTT",
        "G003",
        "G201",
        "G202",
        "ASYNC",
    },
    ignore = {
        "B904",
        "E501",
        "ISC001",
        "RET501",
        "TRY003",
    },
}

local gradle_query = [[
  (closure
      (assignment
        (identifier) @key (#eq? @key "lineLength")
        (number_literal) @length
      )
  )
]]

local toml_query = [[
  (table
    (dotted_key) @dotkey (#eq? @dotkey "tool.black")
      (pair
        (bare_key) @barekey (#eq? @barekey "line-length")
        (integer) @length
      )
  )
]]

---@param ignores table
---@return table<string>
local function exclude_ignores(ignores)
    return vim.iter(ignores):filter(function(str)
        for _, prefix in ipairs(ruff_prefixes) do
            if string.sub(str, 1, #prefix) == prefix then
                return false
            end
        end

        -- ruff doesn't implement flake8's W503.
        if vim.tbl_contains({ "E128", "W503", "" }, str) then
            return false
        end

        return true
    end)
end

---@param filename string
---@return string
local find_file = function(filename)
    local opts_d = { stop = vim.uv.cwd(), type = "file" }
    local opts_u = vim.tbl_extend("force", opts_d, { upward = true })

    return vim.fs.find(filename, opts_d)[1] or vim.fs.find(filename, opts_u)[1]
end

---@param filename string
---@param language string
---@param query_string string
---@return table<string>|nil
local format_args_from_treesitter = function(filename, language, query_string)
    local args = {}
    local config_file = find_file(filename)

    if config_file == nil or vim.uv.fs_stat(config_file) == nil then
        return nil
    end

    local lines = {}
    for line in io.lines(config_file) do
        lines[#lines + 1] = line
    end

    local config_buffer = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_lines(config_buffer, 0, -1, false, lines)

    local root = vim.treesitter.get_parser(config_buffer, language, {}):parse()[1]:root()

    local query = vim.treesitter.query.parse(language, query_string)

    for id, node in query:iter_captures(root, config_buffer, 0, -1) do
        if query.captures[id] == "length" then
            args["lineLength"] = tonumber(vim.treesitter.get_node_text(node, config_buffer))
        end
    end

    vim.api.nvim_buf_delete(config_buffer, {})

    if #args > 0 then
        return args
    end
end

-- Extract arguments to pass to the ruff formatter.
--
-- Check build.gradle (work) and pyproject.toml.
--
---@return table<string>
M.format_args = function()
    -- stylua: ignore
    return format_args_from_treesitter("pyproject.toml", "toml", toml_query) or
           format_args_from_treesitter("build.gradle", "groovy", gradle_query) or
           {}
end

-- Config for ruff-lsp as a Lua table.
---@return table<string>
M.lint_args = function()
    -- Extract config out of setup.cfg if it exists and use some defaults.
    local config = vim.tbl_deep_extend("force", {}, ruff_default_config)

    local config_file = find_file("setup.cfg")

    if config_file ~= nil and vim.uv.fs_stat(config_file) ~= nil then
        local matches = {
            ["^max%-line%-length"] = "lineLength",
            ["^ignore%s*="] = "ignore",
            ["^extend%-ignore%s*="] = "extendIgnore",
        }

        for line in io.lines(config_file) do
            for pattern, key in pairs(matches) do
                if line:match(pattern) then
                    local match = line:match("%s*=%s*(.*)")

                    if key == "lineLength" then
                        ---@type number
                        config[key] = tonumber(match)
                    else
                        -- --extend-ignore has been deprecated in favor of --extend.
                        ---@type table<string>
                        for _, ignore in exclude_ignores(vim.split(match, "%s*,%s*")) do
                            table.insert(config["ignore"], ignore)
                        end
                    end
                end
            end
        end
    end

    return config
end

local join_quoted = function(list)
    local quoted_items = {}

    for _, item in ipairs(list) do
        table.insert(quoted_items, '"' .. item .. '"')
    end

    return table.concat(quoted_items, ", ")
end

M.write_config = function()
    local path = vim.uv.cwd() .. "/ruff.toml"

    local config = vim.tbl_deep_extend("force", ruff_default_config, M.lint_args(), M.format_args())

    local fd = vim.uv.fs_open(path, "w+", tonumber("644", 8))

    if fd then
        if config["lineLength"] then
            vim.uv.fs_write(fd, string.format("line-length = %s\n", config["lineLength"]))
        end

        vim.uv.fs_write(fd, "[lint]\n")
        vim.uv.fs_write(fd, "extend-select = [" .. join_quoted(config["select"]) .. "]\n")
        vim.uv.fs_write(fd, "ignore = [" .. join_quoted(config["ignore"]) .. "]\n")

        vim.uv.fs_close(fd)
    end
end

return M
