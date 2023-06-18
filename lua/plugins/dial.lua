return {
    "monaqa/dial.nvim",
    config = function()
        local augend = require("dial.augend")

        -- Replace string case conversions with https://github.com/johmsalas/text-case.nvim ?
        local function to_capital(str)
            return str:gsub("^%l", string.upper)
        end

        local function to_pascal(str)
            return str:gsub("%W*(%w+)", to_capital)
        end

        local function to_snake(str)
            return str:gsub("%f[^%l]%u", "_%1"):gsub("%f[^%a]%d", "_%1"):gsub("%f[^%d]%a", "_%1"):gsub("(%u)(%u%l)", "%1_%2"):lower()
        end

        local function to_camel(str)
            return to_pascal(str):gsub("^%u", string.lower)
        end

        require("dial.config").augends:register_group({
            default = {
                augend.integer.alias.decimal,
                augend.integer.alias.hex,
                augend.integer.alias.octal,
                augend.integer.alias.binary,
                augend.hexcolor.new({}),
                augend.constant.alias.alpha,
                augend.constant.alias.Alpha,
                augend.paren.alias.quote,
                augend.paren.alias.lua_str_literal,
                augend.paren.alias.rust_str_literal,
                augend.paren.alias.brackets,
                augend.semver.alias.semver,
                augend.date.alias["%-m/%-d"],
                augend.date.alias["%H:%M"],
                augend.date.alias["%H:%M:%S"],
                augend.date.alias["%Y-%m-%d"],
                augend.date.alias["%Y/%m/%d"],
                augend.date.alias["%m/%d"],
                augend.constant.new({
                    elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
                }),
                augend.constant.new({
                    elements = {
                        "January",
                        "February",
                        "March",
                        "April",
                        "May",
                        "June",
                        "July",
                        "August",
                        "September",
                        "October",
                        "November",
                        "December",
                    },
                }),
                augend.constant.new({ elements = { "North", "East", "South", "West" } }),
                augend.constant.new({ elements = { "TRUE", "FALSE" } }),
                augend.constant.new({ elements = { "True", "False" } }),
                augend.constant.new({ elements = { "true", "false" } }),
                augend.constant.new({ elements = { "and", "or" } }),
                augend.constant.new({ elements = { "And", "Or" } }),
                augend.constant.new({ elements = { "AND", "OR" } }),
                augend.constant.new({ elements = { "define", "undef" } }),
                augend.constant.new({ elements = { "float64", "float32" } }),
                augend.constant.new({ elements = { "h1", "h2", "h3", "h4", "h5", "h6" } }),
                augend.constant.new({ elements = { "int", "int64", "int32" } }),
                augend.constant.new({ elements = { "on", "off" } }),
                augend.constant.new({ elements = { "On", "Off" } }),
                augend.constant.new({ elements = { "ON", "OFF" } }),
                augend.constant.new({ elements = { "pick", "reword", "edit", "squash", "fixup", "exec" } }),
                augend.constant.new({ elements = { "Up", "Down", "Left", "Right" } }),
                augend.constant.new({ elements = { "up", "down", "left", "right" } }),
                augend.constant.new({ elements = { "yes", "no" } }),
                augend.constant.new({ elements = { "Yes", "No" } }),
                augend.constant.new({ elements = { "YES", "NO" } }),
                augend.constant.new({ elements = { "&&", "||" }, word = false }),
                augend.constant.new({ elements = { ">", "<" }, word = false }),
                augend.constant.new({ elements = { "==", "!=" }, word = false }),
                augend.constant.new({ elements = { "===", "!==" }, word = false }),
                augend.constant.new({ elements = { ">=", "<=" }, word = false }),
                augend.constant.new({ elements = { "++", "--" }, word = false }),
                augend.user.new({
                    find = require("dial.augend.common").find_pattern("%u+"),
                    add = function(text, _, _)
                        return { text = text:lower(), cursor = #text }
                    end,
                }),
                augend.user.new({
                    find = require("dial.augend.common").find_pattern("%l+"),
                    add = function(text, _, _)
                        return { text = text:upper(), cursor = #text }
                    end,
                }),
                -- Cycle through camel, pascal & snake case.
                augend.user.new({
                    find = require("dial.augend.common").find_pattern("[%a_]+"),
                    add = function(text, _, _)
                        if to_camel(text) == text then
                            text = to_snake(text)
                        elseif to_snake(text) == text then
                            text = to_pascal(text)
                        elseif to_pascal(text) == text then
                            text = to_camel(text)
                        end

                        return { text = text, cursor = #text }
                    end,
                }),
            },
        })
    end,
    keys = {
        {
            "<C-a>",
            function()
                return require("dial.map").inc_normal()
            end,
            desc = "Increment Pattern",
            expr = true,
        },
        {
            "<C-x>",
            function()
                return require("dial.map").dec_normal()
            end,
            desc = "Decrement Pattern",
            expr = true,
        },
    },
}
