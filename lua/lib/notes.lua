-- Apple Notes through the apple-notes-mcp CLI.
local M = {}

local cmd = "apple-notes-mcp"

---@param args string[]
---@param stdin string?
---@return string?
local function run(args, stdin)
    local result = vim.system({ cmd, unpack(args) }, { stdin = stdin, text = true }):wait()

    if result.code ~= 0 then
        vim.notify(vim.trim(result.stderr or ""), vim.log.levels.ERROR, { title = "Apple Notes" })
        return nil
    end

    return result.stdout
end

---@param buf integer
---@return string
local function id(buf)
    return vim.api.nvim_buf_get_name(buf):match("^applenotes://(.+)$") or ""
end

---@param buf integer
function M.read(buf)
    local out = run({ "notes", "read", id(buf) })

    if not out then
        return
    end

    -- A header line, `---`, then one line per note paragraph; print adds the final newline.
    local header, markdown = out:match("^(.-)\n%-%-%-\n(.*)\n$")

    if not header or not markdown then
        vim.notify("Unexpected `notes read` output", vim.log.levels.ERROR, { title = "Apple Notes" })
        return
    end

    vim.bo[buf].buftype = "acwrite"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = true

    -- No undo step for the load: undoing it would empty the buffer, and a write would empty the note.
    vim.bo[buf].undolevels = -1
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(markdown, "\n"))
    vim.bo[buf].undolevels = -123456

    vim.b[buf].apple_notes_version = header:match("| version: (%S+)")
    vim.bo[buf].modifiable = not header:find("| shared with you, read-only", 1, true)
    vim.bo[buf].modified = false
    vim.bo[buf].filetype = "markdown"
end

---@param buf integer
function M.write(buf)
    if not vim.bo[buf].modified then
        return
    end

    local markdown = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    local out = run({ "notes", "edit", id(buf), "--version", vim.b[buf].apple_notes_version, "--rewrite", "-" }, markdown)

    if out then
        vim.b[buf].apple_notes_version = out:match("id: %S+ | version: (%S+)")
        vim.bo[buf].modified = false
    end
end

---@param item snacks.picker.Item
---@param picker snacks.Picker
local function format(item, picker)
    local ret = { { item.note.title }, { "  " .. item.note.folder, "SnacksPickerDir" } }

    if picker.opts.live and item.note.snippet then
        table.insert(ret, { "  " .. item.note.snippet, "SnacksPickerComment" })
    end

    return ret
end

-- Full-text search of titles and text; toggle live (<C-g>) off to fuzzy match titles.
function M.pick()
    Snacks.picker.pick({
        title = "Apple Notes",
        live = true,
        supports_live = true,
        matcher = { sort_empty = false },
        finder = function(opts, ctx)
            ---@type string[]
            local args = { "--list-json" }

            if opts.live and ctx.filter.search ~= "" then
                args[2] = ctx.filter.search
            end

            return require("snacks.picker.source.proc").proc(
                ctx:opts({
                    cmd = cmd,
                    args = args,
                    transform = function(item)
                        local ok, note = pcall(vim.json.decode, item.text)

                        if not ok then
                            return false
                        end

                        item.note = note
                        item.text = note.title .. " " .. note.folder
                    end,
                }),
                ctx
            )
        end,
        format = format,
        preview = function(ctx)
            Snacks.picker.preview.cmd({ cmd, "notes", "read", ctx.item.note.id }, ctx, { ft = "markdown" })
        end,
        confirm = function(picker, item)
            picker:close()

            if item then
                vim.cmd.edit("applenotes://" .. item.note.id)
            end
        end,
    })
end

return M
