local ls = require("luasnip")

local c = ls.choice_node
local d = ls.dynamic_node
local f = ls.function_node
local i = ls.insert_node
local s = ls.snippet
local r = ls.restore_node
local t = ls.text_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")

local dataclass = function(_, snip, old_state, _)
    local nodes = {}
    table.insert(nodes, snip.captures[1] == "d" and t({ "@dataclass", "" }) or t({ "" }))
    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

local init_fn
init_fn = function()
    return sn(nil, c(1, { t(""), sn(1, { t(", "), i(1), d(2, init_fn) }) }))
end

local init_params = function(args)
    local node = {}
    local a = args[1][1]
    if #a == 0 then
        table.insert(node, t({ "", "\tpass" }))
    else
        local cnt = 1
        for e in string.gmatch(a, " ?([^,]*) ?") do
            if #e > 0 then
                table.insert(node, t({ "", "\tself." }))
                table.insert(node, r(cnt, tostring(cnt), i(nil, e)))
                table.insert(node, t(" = "))
                table.insert(node, t(e))
                cnt = cnt + 1
            end
        end
    end
    return sn(nil, node)
end

return {
    s("loggermod", {
        t({ "logger = logging.getLogger(__name__)" }),
    }),

    s("pdb", {
        t({ "import pdb; pdb.set_trace()" }),
    }),

    s(
        { trig = "ifmain", dscr = "If name == main", snippetType = "autosnippet", regTrig = false },
        fmt(
            [[
            if __name__ == "__main__":
                main()
        ]],
            {}
        )
    ),

    s(
        { trig = "im[port]", regTrig = true, name = "import statement", dscr = "Import statement" },
        fmt("{}", {
            c(1, {
                sn(nil, fmt("import {}", { i(1, "module-name") })),
                sn(nil, fmt("from {} import {}", { i(1, "defaultExport"), i(2, "*") })),
            }),
        })
    ),

    s(
        { trig = "(d?)cl", regTrig = true, name = "(data) class", dscr = "Declare <data>class" },
        fmt("{}class {}({}):\n\tdef __init__(self{}):{}", {
            d(1, dataclass, {}, {}),
            i(2, "Obj"),
            c(3, {
                t({ "" }),
                i(1, "object"),
            }),
            d(4, init_fn),
            d(5, init_params, { 4 }),
        })
    ),

    s(
        { trig = "fn", name = "function", dscr = "Declare function" },
        fmt("def {}({}):\n\tpass", {
            i(1, "function"),
            i(2, ""),
        })
    ),

    s(
        { trig = "init", name = "constructor", dscr = "Class constructor" },
        fmt("def __init__(self{}):{}", {
            d(1, init_fn),
            d(2, init_params, { 1 }),
        })
    ),

    s(
        { trig = "frin", dscr = "For loop", snippetType = "autosnippet", regTrig = false },
        fmta(
            [[
            for <> in <>:
                <>
        ]],
            {
                f(function(args)
                    s = args[1][1]
                    return s:sub(1, 1):lower()
                end, { 1 }),
                i(1),
                i(0, "pass"),
            }
        )
    ),
    s(
        { trig = "fren", dscr = "For enumerate", snippetType = "autosnippet", regTrig = false },
        fmta(
            [[
            for i, <> in enumerate(<>):
                <>
        ]],
            {
                f(function(args)
                    s = args[1][1]
                    return s:sub(1, 1):lower()
                end, { 1 }),
                i(1),
                i(0, "pass"),
            }
        )
    ),

    s(
        { trig = "lc", dscr = "List comprehension", snippetType = "autosnippet", regTrig = false },
        fmta(
            [[
            [<> for <> in <> if <>]
        ]],
            { i(1), i(2), i(3), i(4) }
        )
    ),

    s(
        { trig = "try", dscr = "Try/Except", snippetType = "autosnippet", regTrig = false },
        fmt(
            [[
            try:
               {try}
            except {exception} as e:
                {except}
        ]],
            { try = i(1, "pass"), exception = i(2, "Exception"), except = i(0, "print(e)") }
        ),
        { condition = conds.line_begin }
    ),

    s(
        { trig = "fn", dscr = "Define function or method", snippetType = "autosnippet", regTrig = false },
        fmt(
            [[
            def {}({}{}){}:
                {}
        ]],
            {
                i(1, "function"),
                f(function()
                    local cnode = require("nvim-treesitter.ts_utils").get_node_at_cursor(0)
                    local scope = require("nvim-treesitter.locals").get_scope_tree(cnode)

                    for _, node in ipairs(scope) do
                        if node:type() == "class_definition" then
                            return "self, "
                        end
                    end

                    return ""
                end, {}),
                i(2, "args"),
                i(3, " -> None"),
                i(0, "pass"),
            }
        )
    ),
}
