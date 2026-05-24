local M = {}

local function uppercase_first(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

---Return the source of the diagnostic under the cursor, if any.
---@return string?
local function cursor_diagnostic_source()
    local pos = vim.api.nvim_win_get_cursor(0)
    local lnum = pos[1] - 1
    local col = pos[2]

    for _, diagnostic in ipairs(vim.diagnostic.get(0, { lnum = lnum })) do
        if col >= diagnostic.col and col <= (diagnostic.end_col or diagnostic.col) then
            return diagnostic.source
        end
    end
end

---Add a word to the ~/.typos.toml file.
---@param word string
function M.add_word_to_typos(word)
    --
    local path = vim.fs.abspath("~/.typos.toml")
    local config = nvim.file.read_toml(path)
    local toml = require("toml")

    if not config then
        return
    end

    local chosen = vim.fn.confirm("Choose section: ", ("&Default\n&%s\n&Cancel"):format(uppercase_first(vim.bo.filetype)))

    if chosen == 0 then
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

    nvim.file.write(path, toml.encode(config))
end

---Add a word to the codebook global `words` allowlist, preserving comments.
---@param word string
function M.add_word_to_codebook(word)
    --
    local path = vim.fs.abspath("~/.config/codebook/codebook.toml")
    local content = nvim.file.read(path)

    if not content then
        Snacks.notify.error("Couldn't read " .. path)
        return
    end

    local updated, count = content:gsub("(words%s*=%s*%[)([^%]]*)(%])", function(head, body, tail)
        if body:find('"' .. word .. '"', 1, true) then
            return head .. body .. tail
        end

        local entry = '"' .. word .. '"'

        if vim.trim(body) == "" then
            return head .. entry .. tail
        end

        return head .. body .. ", " .. entry .. tail
    end, 1)

    if count == 0 then
        Snacks.notify.error("No `words` array found in " .. path)
        return
    end

    nvim.file.write(path, updated)

    -- codebook-lsp reloads its config when notified of a watched-file change.
    for _, client in ipairs(vim.lsp.get_clients({ name = "codebook" })) do
        client:notify("workspace/didChangeWatchedFiles", {
            changes = { { uri = vim.uri_from_fname(path), type = 2 } },
        })
    end
end

---Add the word under the cursor to the spell list backing its diagnostic.
function M.add_word()
    local word = vim.fn.expand("<cword>", false, false)
    local source = cursor_diagnostic_source()

    if source and source:lower():find("codebook", 1, true) then
        M.add_word_to_codebook(word)
    else
        M.add_word_to_typos(word)
    end
end

return M
