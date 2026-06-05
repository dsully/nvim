local M = {}

---@class Child
---@field start integer
---@field end_ integer
---@field name string

---@class Opts
---@field bufnr integer
---@field range Range2
---@field groups string[]

M.node_name_fields = {
    "name",
    "declarator",
    "path",
    "field",
}

M.node_name_types = {
    "identifier",
    "system_lib_string",
    "string_literal",
}

---@param bufnr integer
---@param types string[]
---@return vim.treesitter.Query?
M.build_type_query = function(bufnr, types)
    if #types == 0 then
        return nil
    end

    local filetype = vim.api.nvim_get_option_value("filetype", {
        buf = bufnr,
    })

    local query = "["

    for _, type in ipairs(types) do
        query = query .. "(" .. type .. ")"
    end

    query = query .. "] @_typequery"

    return vim.treesitter.query.parse(filetype, query)
end

---@param children Child[]
---@return nil
M.clear_children = function(children)
    table.sort(children, function(a, b)
        return a.end_ > b.end_
    end)

    for _, child in ipairs(children) do
        local start_row = child.start
        local end_row = child.end_

        vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, {})
    end
end

---@param types_query vim.treesitter.Query?
---@param captures string[]
---@param ceil_node TSNode
---@param textobjects_query vim.treesitter.Query?
---@param range_filter (fun(iter: fun(): TSNode?): fun(): TSNode?)?
---@param opts Opts
---@return fun(): TSNode?
M.get_query_iterator = function(types_query, captures, ceil_node, textobjects_query, range_filter, opts)
    local query_iter

    if types_query ~= nil then
        query_iter = M.get_type_query_iterator(types_query, ceil_node, opts)
    end

    if #captures > 0 then
        local filtered_to_iter = M.get_textobject_query_iterator(captures, textobjects_query, ceil_node, opts)

        if not query_iter then
            query_iter = filtered_to_iter
        else
            query_iter = M.compose_iterators({ query_iter, filtered_to_iter })
        end
    end

    if not query_iter then
        error("Group contains neither a textobjects or type query iterator, this is very strange and should definitely not happen")
    end

    if range_filter then
        query_iter = range_filter(query_iter)
    end

    return query_iter
end

---@param captures string[]
---@param textobjects_query vim.treesitter.Query?
---@param ceil_node TSNode
---@param opts table
---@return fun(): TSNode?
M.get_textobject_query_iterator = function(captures, textobjects_query, ceil_node, opts)
    ---
    if not textobjects_query then
        error("You need to activate Treesitter textobjects to use captures in your sortgroup")
    end

    local start, end_ = M.unpack_range_end_exclusive(opts.range)
    local to_iter = textobjects_query:iter_captures(ceil_node, opts.bufnr, start or 0, end_)

    return M.get_query_node_iterator(function()
        while true do
            local capture = { to_iter() }

            if not capture[1] then
                return nil
            end

            if vim.tbl_contains(captures, textobjects_query.captures[capture[1]]) then
                return capture[1], capture[2], capture[3], capture[4], capture[5]
            end
        end
    end)
end

---@param types_query vim.treesitter.Query
---@param ceil_node TSNode
---@param opts Opts
M.get_type_query_iterator = function(types_query, ceil_node, opts)
    local start, end_ = M.unpack_range_end_exclusive(opts.range)

    return M.get_query_node_iterator(types_query:iter_captures(ceil_node, opts.bufnr, start or 0, end_))
end

---@param node_iter fun(): TSNode?
---@param range Range2
M.read_children = function(node_iter, range)
    local children = {}

    local to_pos = 0

    local function out_of_range(sibling)
        return range and (sibling:start() < range[1] or sibling:end_() > range[2])
    end

    while true do
        local node = node_iter()

        if not node then
            break
        end

        if node:named() then
            local start = node:start()
            local end_ = node:end_()

            -- Include the whole contiguous run of preceding extra nodes superfluous to
            -- grammar (typically comments, e.g. a LuaCATS ---@param/---@return block).
            -- Walk back one sibling at a time so multi-line annotation blocks stay
            -- attached to their node instead of being orphaned at the top of the scope.
            local prev_sibling = node:prev_named_sibling()

            while prev_sibling and prev_sibling:extra() and prev_sibling:end_() + 1 == start do
                if out_of_range(prev_sibling) then
                    break
                end

                start = prev_sibling:start()
                prev_sibling = prev_sibling:prev_named_sibling()
            end

            -- Extend the range of the node to the beginning of next sibling if it exists and is in range,
            -- this makes sures padding around text objects is maintained when sorting
            local next_sibling = node:next_named_sibling()

            if next_sibling and out_of_range(next_sibling) then
                next_sibling = nil
            end

            if next_sibling then
                local next_sibling_start = next_sibling:start()
                end_ = next_sibling_start - 1
            end

            if end_ + 1 > to_pos then
                to_pos = end_ + 1
            end

            table.insert(children, { start = start, end_ = end_, name = M.get_node_name(node) })
        end
    end

    table.sort(children, function(a, b)
        return a.name > b.name
    end)

    return children, to_pos
end

---@param opts Opts
M.sort = function(opts)
    local ok, floor_node, ceil_node, range_filter

    -- Ensure the syntax tree is parsed before querying it. get_node and
    -- named_node_for_range return nil on an unparsed tree (e.g. when treesitter
    -- highlighting isn't active for the buffer), which crashes the iterators below.
    local has_parser, parser = pcall(vim.treesitter.get_parser, opts.bufnr)

    if not has_parser or not parser then
        vim.notify("treesorter: no treesitter parser for this buffer", vim.log.levels.ERROR)
        return
    end

    parser:parse(true)

    local textobjects_query = M.get_textobjects_query(opts.bufnr)

    if opts.range then
        floor_node = M.find_smallest_node_for_range(opts.bufnr, opts.range)
        ceil_node = floor_node
        range_filter = M.get_range_filter(opts.range)
    else
        floor_node = vim.treesitter.get_node({
            bufnr = opts.bufnr,
            pos = opts.pos,
            ignore_injections = false,
        })

        ceil_node = M.find_root_node(opts.bufnr, floor_node)
    end

    if not floor_node or not ceil_node then
        vim.notify("treesorter: no syntax node at the cursor or selection", vim.log.levels.WARN)
        return
    end

    for _, group in ipairs(opts.groups) do
        local types = {}
        local captures = {}

        for type in group:gmatch("([^+]+)") do
            if type:find("@") == 1 then
                table.insert(captures, type:sub(2))
            else
                table.insert(types, type)
            end
        end

        local types_query = M.build_type_query(opts.bufnr, types)

        local query_iter = M.get_query_iterator(types_query, captures, ceil_node, textobjects_query, range_filter, opts)

        local container = M.find_container_from_query(query_iter, floor_node)

        local parent_filter = M.get_parent_filter(container)

        -- Refresh iterator since it's been exhausted, and wrap it in parent filter
        query_iter = parent_filter(M.get_query_iterator(types_query, captures, ceil_node, textobjects_query, range_filter, opts))

        local children, to_pos

        ok, children, to_pos = pcall(M.read_children, query_iter, opts.range)

        if ok == false then
            print(children)
            break
        end

        M.write_children(children, to_pos)
        M.clear_children(children)
    end
end

-- ---@param children TSNode[]
---@param to_pos integer
---@return nil
M.write_children = function(children, to_pos)
    for _, child in ipairs(children) do
        local start_row = child.start
        local end_row = child.end_

        local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)

        vim.api.nvim_buf_set_lines(0, to_pos, to_pos, false, lines)
    end
end

---@param needle TSNode
---@param haystack TSNode[]
---@return TSNode
local function find_smallest_node_containing_oneof(needle, haystack)
    local parent = needle:parent()

    if not parent then
        return needle
    end

    for _, node in ipairs(haystack) do
        if needle:equal(node) then
            return parent
        end
    end

    return find_smallest_node_containing_oneof(parent, haystack)
end

M.compose_iterators = function(iterators)
    return function()
        for _, iter in ipairs(iterators) do
            local value = iter()

            if value then
                return value
            end
        end

        return nil
    end
end

---@param query_iter fun(): TSNode?
---@param floor_node TSNode
M.find_container_from_query = function(query_iter, floor_node)
    ---@type TSNode[]
    local captured_nodes = {}

    while true do
        local node = query_iter()

        if not node then
            break
        end

        table.insert(captured_nodes, node)
    end

    -- First check the children of the floor node for matches to see if the floor node should be the container
    local child_it = floor_node:iter_children()

    while true do
        local child = child_it()

        if not child then
            break
        end

        for _, captured_node in ipairs(captured_nodes) do
            if child:equal(captured_node) then
                return floor_node
            end
        end
    end

    -- Then traverse up until the ceiling node checking for the container
    return find_smallest_node_containing_oneof(floor_node, captured_nodes)
end

---@param bufnr integer
---@param node TSNode?
---@return TSNode
M.find_root_node = function(bufnr, node)
    --
    if not node then
        ---@type TSNode
        node = vim.treesitter.get_node({
            bufnr = bufnr,
            ignore_injections = false,
        })
    end

    local parent = node:parent()

    if not parent then
        return node
    end

    return M.find_root_node(bufnr, parent)
end

---@param bufnr integer
---@param range Range2
---@return TSNode?
M.find_smallest_node_for_range = function(bufnr, range)
    local last_line = vim.api.nvim_buf_get_lines(bufnr or 0, range[2], range[2] + 1, true)

    if #last_line == 0 then
        error("Invalid range")
    end

    local end_col = #last_line[1]

    local parser = vim.treesitter.get_parser(bufnr)

    if parser ~= nil then
        return parser:named_node_for_range({ range[1], 0, range[2], end_col }, { ignore_injections = false })
    end
end

---@param bufnr integer
---@param range Range2
---@return string[]
M.get_captures = function(bufnr, range)
    local node

    if range then
        node = M.find_smallest_node_for_range(bufnr, range)
    else
        node = M.find_root_node(bufnr)
    end

    if not node then
        return {}
    end

    ---@type table<string,boolean>
    local captures_set = {}
    local textobjects_query = M.get_textobjects_query(bufnr)

    if not textobjects_query then
        return {}
    end

    local query_it = textobjects_query:iter_captures(node, bufnr, 0)

    while true do
        local id = query_it()

        if not id then
            break
        end

        local name = textobjects_query.captures[id]

        if name ~= nil and name:find("_") ~= 1 then
            captures_set["@" .. name] = true
        end
    end

    local captures = {}

    for k, _ in pairs(captures_set) do
        captures[#captures + 1] = k
    end

    return captures
end

---@param node TSNode
---@return string?
M.get_node_name = function(node)
    --
    for _, literal_type in ipairs(M.node_name_types) do
        if node:type() == literal_type then
            return M.node_to_string(node)
        end
    end

    for _, field_name in ipairs(M.node_name_fields) do
        local field = node:field(field_name)

        if #field > 0 then
            return M.get_node_name(field[1])
        end
    end

    local iter = node:iter_children()

    while true do
        local child = iter()

        if not child then
            break
        end

        local ok, child_name = pcall(M.get_node_name, child)

        if ok then
            return child_name
        end
    end

    error("Node type not supported: " .. node:type())
end

---@param parent TSNode
---@return fun(iter: fun(): TSNode?): fun(): TSNode?
M.get_parent_filter = function(parent)
    ---@param iter fun(): TSNode?
    return function(iter)
        --
        ---@return TSNode?
        return function()
            while true do
                local node = iter()

                if not node then
                    return nil
                end

                if node:parent():equal(parent) then
                    return node
                end
            end
        end
    end
end

---@param iter fun(): integer?, TSNode?, vim.treesitter.query.TSMetadata?, TSQueryMatch?, TSTree?
---@return fun(): TSNode?
M.get_query_node_iterator = function(iter)
    return function()
        local capture = { iter() }

        if not capture then
            return nil
        end

        return capture[2]
    end
end

---@param range Range2
---@return fun(iter: fun(): TSNode?): fun(): TSNode?
M.get_range_filter = function(range)
    ---@param iter fun(): TSNode?
    return function(iter)
        --
        ---@return TSNode?
        return function()
            while true do
                local child = iter()

                if not child then
                    return nil
                end

                local start_row = child:start()
                local end_row = child:end_()

                if start_row >= range[1] and end_row <= range[2] then
                    return child
                end
            end
        end
    end
end

---@param bufnr integer
---@return vim.treesitter.Query?
M.get_textobjects_query = function(bufnr)
    local filetype = vim.api.nvim_get_option_value("filetype", {
        buf = bufnr,
    })

    local ok, textobjects_query = pcall(vim.treesitter.query.get, filetype, "textobjects")

    if ok == false then
        textobjects_query = nil
    end

    return textobjects_query
end

---@param bufnr integer
---@param range Range2
---@return string[]
M.get_types = function(bufnr, range)
    ---@type TSNode?
    local node

    if range then
        node = M.find_smallest_node_for_range(bufnr, range)
    else
        node = M.find_root_node(bufnr)
    end

    if not node then
        return {}
    end

    local typeset = M.get_typeset(node)

    ---@type string[]
    local types = {}

    for type, _ in pairs(typeset) do
        table.insert(types, type)
    end

    table.sort(types)

    return types
end

---@param node TSNode
---@param typeset table<string, boolean>?
---@return table<string, boolean>
M.get_typeset = function(node, typeset)
    if not typeset then
        ---@type table<string, boolean>?
        typeset = {}
    end

    ---@type string
    local node_type = node:type()

    if not typeset[node_type] then
        typeset[node_type] = true
    end

    local iter = node:iter_children()

    while true do
        local child = iter()

        if not child then
            break
        end

        typeset = M.get_typeset(child, typeset)
    end

    return typeset
end

---@param node TSNode?
---@return string?
M.node_to_string = function(node)
    local text = M.node_to_text(node)

    if not text then
        return nil
    end

    return table.concat(text, "\n")
end

---@param node TSNode?
---@return string[]?
M.node_to_text = function(node)
    if not node then
        return nil
    end

    local start_row, start_col = node:start()
    local end_row, end_col = node:end_()

    return vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
end

---@param range Range2
---@return integer?, integer?
M.unpack_range_end_exclusive = function(range)
    if not range then
        return nil, nil
    end

    return range[1], range[2] + 1
end

do
    vim.api.nvim_create_user_command("TSort", function(o)
        local groupstr = o.args
        local groups = {}

        for arg in groupstr:gmatch("%S+") do
            table.insert(groups, arg)
        end

        ---@type Range2
        local range

        if o.range == 2 then
            range = { o.line1 - 1, o.line2 - 1 }
        end

        M.sort({
            groups = groups,
            range = range,
            bufnr = vim.api.nvim_win_get_buf(0),
        })
    end, {
        nargs = "*",
        range = "%",

        ---@type arg_lead string
        ---@type cmd_line string
        complete = function(arg_lead, cmd_line)
            local visual_mod = string.find(cmd_line, "'<,'>") == 1

            ---@type Range2
            local range = {}

            if visual_mod then
                range = { vim.api.nvim_buf_get_mark(0, "<")[1] - 1, vim.api.nvim_buf_get_mark(0, ">")[1] - 1 }
            end

            local bufnr = vim.api.nvim_win_get_buf(0)

            ---@type string[]
            local all_completions = {}
            local all_captures = M.get_captures(bufnr, range)
            local all_types = M.get_types(bufnr, range)

            for i = 1, #all_captures do
                all_completions[#all_completions + 1] = all_captures[i]
            end

            for i = 1, #all_types do
                all_completions[#all_completions + 1] = all_types[i]
            end

            if not arg_lead then
                return all_types
            end

            local arg_part_idx = arg_lead:find("[^+]+$")

            local completions = all_completions

            if not arg_part_idx then
                for k, v in ipairs(completions) do
                    completions[k] = arg_lead .. v
                end

                return completions
            end

            local history_part = arg_lead:sub(1, arg_part_idx - 1)
            local arg_part = arg_lead:sub(arg_part_idx)

            completions = vim.tbl_filter(function(type)
                return type:find(arg_part) == 1
            end, completions)

            if #completions == 1 and completions[1] == arg_part then
                history_part = history_part .. arg_part .. "+"
                completions = all_completions
            end

            for k, type in ipairs(completions) do
                completions[k] = history_part .. type
            end

            return completions
        end,
    })
end

return M
