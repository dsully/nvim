local ls = require("luasnip")

local d = ls.dynamic_node
local f = ls.function_node
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

return {
    s("loggermod", {
        t({ "logger = logging.getLogger(__name__)" }),
    }),

    s(
        { trig = "class", name = "Class Definition", dscr = "Define a new class" },
        fmt(
            [[
            class {}:
                def __init__(self) -> None:
                    {}
            ]],
            {
                i(1),
                i(2, "pass"),
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
}
