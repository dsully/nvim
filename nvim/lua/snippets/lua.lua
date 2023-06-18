local ls = require("luasnip")

local d = ls.dynamic_node
local f = ls.function_node
local i = ls.insert_node
local s = ls.snippet
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

return {
    s(
        { trig = "req", name = "Require" },
        fmt("local {} = require('{}')", {
            d(2, function(args)
                local pos = 1
                local str = args[1][1]
                local point = string.byte(".")
                for idx = 1, #str do
                    if str:byte(idx) == point then
                        pos = idx + 1
                    end
                end
                return sn(nil, i(1, str:sub(pos)))
            end, { 1 }),
            i(1),
        })
    ),

    s(
        { trig = "lfn", dscr = "Create a local function", snippetType = "autosnippet", regTrig = false },
        fmta(
            [[
                local <> = function(<>)
                    <>
                end
	        ]],
            {
                i(1),
                i(2),
                i(3),
            }
        )
    ),

    s(
        { trig = "mfn", dscr = "Create module function", snippetType = "autosnippet", regTrig = false },
        fmta(
            [[
                <>.<> = function(<>)
                    <>
                end
	        ]],
            {
                i(1, "M"),
                i(2),
                i(3),
                i(4),
            }
        )
    ),

    s(
        {
            trig = "if",
            condition = function()
                local ignored_nodes = { "string", "comment" }
                local pos = vim.api.nvim_win_get_cursor(0)
                local row, col = pos[1] - 1, pos[2] - 1
                local node_type = vim.treesitter.get_node({ pos = { row, col } }):type()
                return not vim.tbl_contains(ignored_nodes, node_type)
            end,
        },
        fmt(
            [[
        if {} then
          {}
        end
      ]],
            { i(1), i(2) }
        )
    ),
}
