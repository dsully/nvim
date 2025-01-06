local M = {}

local function uppercase_first(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

---Add a word to the ~/.typos.toml file.
---@param word string
M.add_word_to_typos = function(word)
    --
    local fs = require("helpers.file")

    local path = vim.g.home .. "/.typos.toml"
    local config = fs.read_toml(path)

    if not config then
        return
    end

    local chosen = vim.fn.confirm("Choose section: ", ("&Default\n&%s\n&Cancel"):format(uppercase_first(vim.bo.filetype)))

    if chosen == nil then
        return
    end

    local choice = chosen == 1 and "default.extend-words" or "type." .. vim.bo.filetype .. ".extend-words"

    -- Create the section if it doesn't exist
    local sections = vim.split(choice, "%.")

    for i = 1, #sections do
        local section = sections[i]

        if not config[section] then
            config[section] = {}
        end

        config = config[section]
    end

    config[word] = word

    fs.write(path, tostring(config))
end

return M
