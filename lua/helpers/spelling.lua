local M = {}

local fs = require("helpers.file")

-- This comes from vhyrro/luarocks.nvim / the toml-edit rock.
local toml = require("toml_edit")

local function uppercase_first(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

---Add a word to the ~/.typos.toml file.
---@param word string
M.add_word_to_typos = function(word)
    local path = vim.env.HOME .. "/.typos.toml"
    local config = fs.read(path)

    if not config then
        vim.notify("~/.typos.toml file not found!", vim.log.levels.ERROR)
        return
    end

    local choices = {
        "default.extend-words",
        "type." .. vim.bo.filetype .. ".extend-words",
    }

    local selected = vim.fn.confirm("Select section: ", ("&Default\n&%s\n&Cancel"):format(uppercase_first(vim.bo.filetype)))
    local chosen = choices[selected]

    -- Create the section if it doesn't exist
    local sections = vim.split(chosen, "%.")
    local current_table = toml.parse(config)

    for i = 1, #sections do
        local section = sections[i]

        if not current_table[section] then
            current_table[section] = {}
        end

        current_table = current_table[section]
    end

    current_table[word] = word

    fs.write(path, tostring(current_table))
end

return M
