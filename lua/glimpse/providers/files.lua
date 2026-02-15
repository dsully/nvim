local M = {}

local glimpse = require("glimpse")
local util = require("glimpse.util")

---Open file picker using fd command
---@param opts? { hidden?: boolean, follow?: boolean, dirs?: string[] }
function M.files(opts)
    opts = opts or {} --[[@as { hidden?: boolean, follow?: boolean, dirs?: string[] }]]

    local cmd = { "fd", "--type", "f", "--type", "l", "--color", "never", "-E", ".git" }

    if opts.hidden then
        table.insert(cmd, "--hidden")
    end

    if opts.follow then
        table.insert(cmd, "-L")
    end

    if opts.dirs and #opts.dirs > 0 then
        table.insert(cmd, ".")
        vim.list_extend(cmd, opts.dirs)
    end

    local all_files = {}
    local picker = glimpse.pick(all_files, {
        prompt = "> ",
        parser = util.parsers.file,
        on_select = function(selection, data)
            util.jump_to_location(selection, data)
            vim.cmd.normal({ 'g`"', bang = true })
        end,
    })

    vim.system(cmd, {
        text = true,
        stdout = function(_, data)
            if not data then
                return
            end

            vim.list_extend(all_files, vim.split(data, "\n", { trimempty = true }))

            vim.schedule(function()
                if picker then
                    picker:set_items(all_files)
                end
            end)
        end,
    })

    return picker
end

---Open live grep picker using rg command
function M.live_grep()
    return glimpse.pick_async(function(query)
        return {
            "rg",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--color=never",
            "--max-columns=500",
            "--max-columns-preview",
            "--glob=!.git",
            "--",
            query,
        }
    end, {
        prompt = "> ",
        parser = util.parsers.grep,
        on_select = function(selection, data)
            util.jump_to_location(selection, data)
        end,
    })
end

---Grep the word under the cursor
---@param opts? { dirs?: string[] }
function M.grep_word(opts)
    opts = opts or {} --[[@as { dirs?: string[] }]]

    local word = vim.fn.expand("<cword>")

    if not word or word == "" then
        vim.notify("No word under cursor", vim.log.levels.INFO)

        return
    end

    local rg_cmd = {
        "rg",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--color=never",
        "--max-columns=500",
        "--max-columns-preview",
        "--glob=!.git",
        "--fixed-strings",
        "--",
        word,
    }

    if opts.dirs then
        vim.list_extend(rg_cmd, opts.dirs)
    end

    return glimpse.pick_async(function()
        return rg_cmd
    end, {
        prompt = "Word: " .. word .. " > ",
        min_query_len = 0,
        parser = util.parsers.grep,
        on_select = function(selection, data)
            util.jump_to_location(selection, data)
        end,
    })
end

return M
