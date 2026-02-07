local api = vim.api

local M = {}

local lang_cache = {}
local icons_available, mini_icons = pcall(require, "mini.icons")

---Safely set an extmark with error handling
---@param buf integer Buffer handle
---@param ns integer Namespace id
---@param line integer 0-indexed line number
---@param col integer Column number
---@param opts table Extmark options
local function safe_extmark(buf, ns, line, col, opts)
    return pcall(api.nvim_buf_set_extmark, buf, ns, line, col, opts)
end

---Get icon for a file
---@param filename string
---@return string icon, string hl_group
function M.get_file_icon(filename)
    if not icons_available or not mini_icons or not mini_icons.get then
        return "", "Normal"
    end

    local icon, hl = mini_icons.get("file", filename)

    return icon or "", hl or "Normal"
end

---Highlight match positions in a line
---@param buf integer Buffer handle
---@param ns integer Namespace id
---@param line_idx integer 0-indexed line number
---@param line string The line text
---@param query string The search query
function M.highlight_matches(buf, ns, line_idx, line, query)
    if not query or query == "" then
        return
    end

    local line_lower = line:lower()
    local query_lower = query:lower()

    local start_idx = line_lower:find(query_lower, 1, true)
    if start_idx then
        ---@type integer
        local col_start = start_idx - 1
        ---@type integer
        local col_end = col_start + #query
        safe_extmark(buf, ns, line_idx, col_start, {
            end_col = col_end,
            hl_group = "GlimpseMatch",
            priority = 120,
        })
    end
end

---@param filename string
---@return string?
local function get_lang(filename)
    local ft = vim.filetype.match({ filename = filename })
    if not ft then
        local ext = filename:match("%.([^%.]+)$")
        if ext then
            ft = ext
        end
    end

    if not ft then
        return nil
    end

    if lang_cache[ft] then
        return lang_cache[ft]
    end

    local lang = vim.treesitter.language.get_lang(ft) or ft
    local has_lang = pcall(vim.treesitter.language.add, lang)
    if not has_lang then
        lang_cache[ft] = nil

        return nil
    end

    lang_cache[ft] = lang

    return lang
end

---@param buf integer
---@param ns integer
---@param line_idx integer
---@param line string
---@param do_highlight_code boolean
function M.highlight_entry(buf, ns, line_idx, line, do_highlight_code)
    local bufnr = line:match("^(%d+): ")
    if bufnr then
        local path_start = #bufnr + 3
        local path_part = line:sub(path_start)
        local filename = path_part:match("^([^:]+)")

        local icon, icon_hl = M.get_file_icon(filename or "")
        safe_extmark(buf, ns, line_idx, 0, {
            virt_text = { { icon .. " ", icon_hl } },
            virt_text_pos = "inline",
            priority = 100,
        })

        safe_extmark(buf, ns, line_idx, 0, {
            end_col = #bufnr,
            hl_group = "GlimpseLineNr",
            priority = 100,
        })

        local dir_str = path_part:match("^(.*/)")
        if dir_str then
            safe_extmark(buf, ns, line_idx, path_start - 1, {
                end_col = path_start - 1 + #dir_str,
                hl_group = "GlimpseDirectory",
                priority = 100,
            })
        end

        return
    end

    local suffix_start = line:find(":%d+:%d+")
    local path_end = suffix_start and (suffix_start - 1) or #line
    local path_part = line:sub(1, path_end)

    local icon, icon_hl = M.get_file_icon(path_part)
    safe_extmark(buf, ns, line_idx, 0, {
        virt_text = { { icon .. " ", icon_hl } },
        virt_text_pos = "inline",
        priority = 100,
    })

    local dir_str = path_part:match("^(.*/)")
    if dir_str then
        safe_extmark(buf, ns, line_idx, 0, {
            end_col = #dir_str,
            hl_group = "GlimpseDirectory",
            priority = 100,
        })
    end

    if suffix_start then
        local s, e = line:find(":%d+:", suffix_start)
        if s and e then
            safe_extmark(buf, ns, line_idx, s, {
                end_col = e - 1,
                hl_group = "GlimpseLineNr",
                priority = 100,
            })
        end

        if do_highlight_code then
            local _, coords_end = line:find(":%d+:%d+", suffix_start)
            if coords_end then
                local content_start = line:find(":", coords_end)
                if content_start then
                    local content = line:sub(content_start + 1)
                    M.highlight_code(buf, ns, line_idx, content_start, content, path_part)
                end
            end
        end
    end
end

---@param buf integer
---@param ns integer
---@param row integer
---@param start_col integer
---@param content string
---@param filename string
function M.highlight_code(buf, ns, row, start_col, content, filename)
    local lang = get_lang(filename)
    if not lang then
        return
    end

    local ok, parser = pcall(vim.treesitter.get_string_parser, content, lang)
    if not ok or not parser or not parser.parse then
        return
    end

    local trees = parser:parse()
    if not trees or not trees[1] then
        return
    end

    local tree = trees[1]
    local root = tree:root()

    local query = vim.treesitter.query.get(lang, "highlights")
    if not query then
        return
    end

    for id, node, _ in query:iter_captures(root, content, 0, -1) do
        local capture_name = query.captures[id]
        local hl_group = "@" .. capture_name

        local _, c1, _, c2 = node:range()

        safe_extmark(buf, ns, row, start_col + c1, {
            end_col = start_col + c2,
            hl_group = hl_group,
            priority = 110,
        })
    end
end

return M
