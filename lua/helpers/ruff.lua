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
        "TRY200",
    },
}

local gradle_query = [[
  (block
    (unit) @formatter (#eq? @formatter "black")
      (command
        (unit) @key (#eq? @key "lineLength")
        (number) @length
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

local function exclude_ignores(table)
    return vim.iter(table):filter(function(str)
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

local find_file = function(filename)
    local opts_d = { stop = vim.uv.cwd(), type = "file" }
    local opts_u = vim.tbl_extend("force", opts_d, { upward = true })

    return vim.fs.find(filename, opts_d)[1] or vim.fs.find(filename, opts_u)[1]
end

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
            table.insert(args, "line-length = " .. vim.treesitter.get_node_text(node, config_buffer))
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
M.format_args = function()
    -- stylua: ignore
    return format_args_from_treesitter("pyproject.toml", "toml", toml_query) or
           format_args_from_treesitter("build.gradle", "groovy", gradle_query) or
           {}
end

-- Config for ruff-lsp as a Lua table.
local lint_config = function()
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
                        config["ignore"] = vim.tbl_deep_extend("force", config["ignore"], exclude_ignores(vim.split(match, "%s*,%s*")))
                    end
                end
            end
        end
    end

    return config
end

-- Massage the ruff config into something the CLI can handle.
M.lint_args = function()
    local config = lint_config()

    local args = {
        "extend-select = " .. vim.fn.join(config["select"], ","),
        "ignore = " .. vim.fn.join(exclude_ignores(config["ignore"]), ","),
    }

    if config["lineLength"] then
        table.insert(args, "line-length = " .. config["lineLength"])
    end

    return args
end

M.write_config = function()
    local path = vim.uv.cwd() .. "/ruff.toml"

    local f_args = M.format_args()
    local l_args = M.lint_args()

    -- Only write the file if it doesn't exist or there are arguments to write.
    if vim.uv.fs_stat(path) or (vim.tbl_isempty(f_args) and vim.tbl_isempty(l_args)) then
        return
    end

    local fd = vim.uv.fs_open(path, "w+", tonumber("644", 8))

    if fd then
        for _, arg in ipairs(f_args) do
            vim.uv.fs_write(fd, arg)
        end

        for _, arg in ipairs(l_args) do
            vim.uv.fs_write(fd, arg)
        end

        vim.uv.fs_close(fd)
    end
end

return M
