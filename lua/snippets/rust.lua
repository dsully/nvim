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
        return arg[1][1]:match("Result") and "Ok(())" or ""
    end, { index })
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
}
