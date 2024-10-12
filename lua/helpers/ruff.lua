local M = {}

local ruff_prefixes = { "TAE", "PIE" }

---@class RuffConfig
---
---Absolute path to a global Ruff configuration file.
---@field configuration string?
---
---The resolution strategy used to merge configuration set in the editor with configuration set in local `.toml` files.
---@field configurationResolutionStrategy "default" | "prioritizeWorkspace"
---
--- Set paths for the linter and formatter to ignore. See https://docs.astral.sh/ruff/settings/#lint_exclude
---@field exclude table<string>
---
---Whether to register Ruff as capable of handling `source.fixAll` actions.
---@field fixAll boolean
---
---@field format RuffFormatConfig
---
--- Set the used by the formatter and linter. Must be greater than 0 and less than or equal to 320.
---@field lineLength number
---
--- Configuration for the linter.
---@field lint RuffLintConfig
---
---Whether to register Ruff as capable of handling `source.organizeImports` actions.
---@field organizeImports boolean
M.defaults = {
    ---
    ---@class RuffCodeActionConfig
    ---@field disableRuleComment RuffCodeActionDisableRuleComment
    ---@field fixViolation RuffCodeActionFixViolation
    codeAction = {
        --
        ---@class RuffCodeActionDisableRuleComment
        ---Whether to display Quick Fix actions to disable rules via `noqa` suppression comments.
        ---@field enabled boolean
        disableRuleComment = {
            enabled = true,
        },
        --
        ---@class RuffCodeActionFixViolation
        ---Whether to display Quick Fix actions to auto-fix violations.
        ---@field enabled boolean
        fixViolation = {
            enabled = true,
        },
    },
    configurationResolutionStrategy = "prioritizeWorkspace",
    exclude = {},
    fixAll = true,
    --
    ---@class RuffFormatConfig
    ---@field preview boolean
    format = {
        preview = false,
    },
    lineLength = 180,
    --
    ---@class RuffLintConfig
    ---@field enabled boolean
    --- "Set rule codes to enable. Use `ALL` to enable all rules. See https://docs.astral.sh/ruff/settings/#lint_select
    ---@field select table<string>
    --- Enable additional rule codes on top of existing configuration, instead of overriding it. Use `ALL` to enable all rules.
    ---@field extendSelect table<string>
    --- Set rule codes to disable. See https://docs.astral.sh/ruff/settings/#lint_ignore
    ---@field ignore table<string>
    lint = {
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
    },
    organizeImports = true,
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

---@param ignores table<string>
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
---@return number?
local line_length_from_treesitter = function(filename, language, query_string)
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

    ---@type number?
    local length

    for id, node in query:iter_captures(root, config_buffer, 0, -1) do
        if query.captures[id] == "length" then
            length = tonumber(vim.treesitter.get_node_text(node, config_buffer))
            break
        end
    end

    vim.api.nvim_buf_delete(config_buffer, {})

    return length
end

-- Extract arguments to pass to the ruff formatter.
--
-- Check build.gradle (work) and pyproject.toml.
--
---@return number?
M.line_length = function()
    -- stylua: ignore
    return line_length_from_treesitter("pyproject.toml", "toml", toml_query) or
           line_length_from_treesitter("build.gradle", "groovy", gradle_query)
end

-- Extract config out of setup.cfg if it exists and use some defaults.
---@return RuffConfig
M.config = function()
    --
    ---@type number?
    local length = nil
    local config = M.defaults

    local config_file = find_file("setup.cfg")

    if config_file ~= nil and vim.uv.fs_stat(config_file) ~= nil then
        local matches = {
            ["^max%-line%-length"] = "lineLength",
            ["^ignore%s*="] = "ignore",
            ["^extend%-ignore%s*="] = "extendIgnore",
        }

        for l in io.lines(config_file) do
            -- Doesn't appear to be a better way to do this.
            ---@type string
            local line = l

            for pattern, key in pairs(matches) do
                if line:match(pattern) then
                    --
                    ---@type string
                    local match = line:match("%s*=%s*(.*)")

                    if key == "lineLength" then
                        length = tonumber(match)
                    else
                        -- 'extend-ignore' has been deprecated in favor of 'extend'
                        for _, i in exclude_ignores(vim.split(match, "%s*,%s*")) do
                            ---@type string
                            local ignore = i

                            table.insert(config.lint.ignore, ignore)
                        end
                    end
                end
            end
        end
    end

    -- Priority: pyproject.toml > build.gradle > setup.cfg > global defaults.
    config.lineLength = M.line_length() or length or config.lineLength

    config.configuration = vim.env.XDG_CONFIG_HOME .. "/ruff/ruff.toml"

    return config
end

---@param command string
M.command = function(command)
    --
    return function()
        for _, client in ipairs(vim.lsp.get_clients({ name = "ruff" })) do
            client.request(vim.lsp.protocol.Methods.workspace_executeCommand, {
                command = command,
                arguments = {
                    {
                        uri = vim.uri_from_bufnr(0),
                        version = vim.lsp.util.buf_versions[vim.api.nvim_get_current_buf()],
                    },
                },
            })
        end
    end
end

return M
