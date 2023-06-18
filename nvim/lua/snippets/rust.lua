local luasnip = require("luasnip")

local c = luasnip.choice_node
local d = luasnip.dynamic_node
local f = luasnip.function_node
local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node
local sn = luasnip.snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

local function ok_if_result(index)
    return f(function(arg)
        if arg[1][1]:match("Result") then
            return "Ok(())"
        else
            return ""
        end
    end, { index })
end

local function query_structs()
    local parser = vim.treesitter.get_parser()
    local tstree = parser and parser:parse()[1]
    local root = tstree and tstree:root()
    local expr = [[
        (struct_item
            name: (_) @st-name
            (type_parameters (_) )? @st-type-parameters
        )
    ]]
    local names = {}
    local query = vim.treesitter.query.parse("rust", expr)

    for _, match, _ in query:iter_matches(root, 0, root:start(), root:end_()) do
        local name = {}
        for id, node in pairs(match) do
            if query.captures[id] == "st-name" then
                table.insert(name, 1, vim.treesitter.get_node_text(node, 0))
            elseif query.captures[id] == "st-type-parameters" then
                table.insert(name, 2, vim.treesitter.get_node_text(node, 0))
            end
        end

        if name then
            table.insert(names, vim.fn.join(name, ""))
        end
    end

    return names
end

local same = function(index)
    return f(function(args)
        return args[1]
    end, { index })
end

return {
    s(
        "main",
        fmta(
            [[fn main() <>{
    <>
    <>
}]],
            {
                c(1, {
                    t(""),
                    t("-> std::result::Result<(), Box<dyn std::error::Error>>"),
                    t("-> Result<()>"),
                }),
                i(2),
                ok_if_result(1),
            }
        )
    ),

    s("amain", {
        t("#[tokio::main]"),
        d(1, function(_, snip)
            if #snip.captures == 0 then
                return sn(nil, {
                    t({ "", "async fn main() -> anyhow::Result<()> {", "\t" }),
                    i(1),
                    t({ "", "}" }),
                })
            else
                return sn(nil, t(""))
            end
        end, {}),
    }, {
        callbacks = {
            [-1] = {
                ---@diagnostic disable:undefined-global
                [events.pre_expand] = function(node, event_args)
                    local row, _ = unpack(event_args.expand_pos)
                    local next_line = vim.api.nvim_buf_get_lines(0, row + 1, row + 2, false)[1]

                    if next_line then
                        local main_fn = next_line:match("^%s*(fn main.*)$")
                        if main_fn then
                            vim.api.nvim_buf_set_lines(0, row + 1, row + 2, false, { "async " .. main_fn })
                            node.captures[1] = main_fn
                        elseif next_line:match("^%s*async%s+fn main.*$") then
                            node.captures[1] = next_line
                        end
                    end
                end,
            },
        },
    }),

    s(
        { trig = "afn", dscr = "Create an async function", snippetType = "autosnippet", regTrig = false },
        fmta(
            [[
                async fn <>(<>) ->> <> {
                    <>
                }
            ]],
            { i(1), i(2), i(3, "()"), i(4, "()") }
        )
    ),

    s(
        { trig = "fn", dscr = "Create a function", snippetType = "autosnippet", regTrig = false },
        fmta(
            [[
                fn <>(<>) ->> <> {
                    <>
                }
            ]],
            { i(1), i(2), i(3, "()"), i(4, "()") }
        )
    ),

    s(
        { trig = "fnew", dscr = "Create a new function", snippetType = "autosnippet", regTrig = false },
        fmta(
            [[
                fn new(<>) ->> Self {
                    <>
                }
            ]],
            { i(1), i(2, "()") }
        )
    ),

    s(
        { trig = "iflet", name = "if let ... = ... { ... }" },
        fmt(
            [[
        if let {} = {} {{
            {}
        }}
      ]],
            { i(1), i(2), i(0) }
        )
    ),

    s(
        { trig = "match", name = "match ... { ... }", desc = "Control flow based on pattern matching" },
        fmt(
            [[
        match {} {{
            Some({}) => {},
            None => {},
        }}
      ]],
            { i(1), i(2), i(3), i(0) }
        )
    ),

    s(
        { trig = "enum", name = "enum", dscr = "Declare enum" },
        fmt("#[derive({})]\nenum {} {{\n\t{}\n}}", {
            c(1, {
                sn(nil, fmt("{}", { i(1) })),
                sn(nil, fmt("{}, {}", { i(1, "Debug"), i(2, "PartialEq") })),
                sn(nil, fmt("{}, {}, {}", { i(1, "Debug"), i(2, "PartialEq"), i(3, "Clone") })),
            }),
            i(2, "Name"),
            i(3),
        })
    ),

    s(
        { trig = "struct", name = "struct", dscr = "Declare struct" },
        fmt("#[derive({})]\nstruct {} {{\n\t{}\n}}", {
            c(1, {
                sn(nil, fmt("{}", { i(1) })),
                sn(nil, fmt("{}, {}", { i(1, "Debug"), i(2, "PartialEq") })),
                sn(nil, fmt("{}, {}, {}", { i(1, "Debug"), i(2, "PartialEq"), i(3, "Clone") })),
            }),
            i(2, "Name"),
            i(3),
        })
    ),

    s("pd", fmt([[println!("{}: {{:?}}", {});]], { same(1), i(1) })),

    s("testmod", {
        t({ "#[cfg(test)]", "mod tests {", "    use super::*;", "    ", "    " }),
        i(0),
        t({ "", "}" }),
    }),

    s(
        { trig = "imp", dscr = "Create a implementation" },
        fmt(
            [[
                impl{} {} {{
                    {}
                }}
            ]],
            {
                f(function(args)
                    local _, _, generics = string.find(args[1][1], "%a+(<.+>)")
                    return generics or ""
                end, { 1 }),
                d(1, function()
                    local structs = query_structs()
                    if #structs == 0 then
                        return sn(nil, i(1, "NewType"))
                    end
                    local choices = {}
                    for _, name in pairs(structs) do
                        table.insert(choices, t(name))
                    end
                    table.insert(choices, i(1, "NewType"))
                    return sn(nil, c(1, choices))
                end, {}),
                i(0),
            }
        )
    ),

    -- s(
    --     { trig = "impl", dscr = "Create method", snippetType = "autosnippet", regTrig = false },
    --     fmta(
    --         [[
    --         impl <> {
    --             fn <>(<>) ->> <> {
    --                 <>
    --             }
    --         }
    --        ]],
    --         {
    --             i(1),
    --             i(2),
    --             i(3, "&self"),
    --             i(4, "()"),
    --             i(5, "()"),
    --         }
    --     )
    -- ),
}
