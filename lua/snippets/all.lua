local luasnip = require("luasnip")

local c = luasnip.choice_node
local d = luasnip.dynamic_node
local s = luasnip.snippet
local t = luasnip.text_node
local sn = luasnip.snippet_node

-- documentation for snippet format inside examples:
-- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua
return {
    s("todo", {
        c(1, {
            t("TODO(dsully): "),
            t("FIXME(dsully): "),
        }),
    }),

    s({
        trig = "#!",
        name = "shebang",
        dscr = "Script interpreter",
        snippetType = "autosnippet",
        regTrig = false,
    }, { d(1, function(_, _)
        return sn(nil, {
            t("#!/usr/bin/env "),
            t(vim.bo.filetype),
        })
    end, {}) }),
}
