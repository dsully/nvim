return function()
    return require("codecompanion.adapters").extend("anthropic", {
        ---@type CodeCompanion.Schema
        schema = {
            ---@see https://docs.anthropic.com/en/docs/about-claude/models
            model = {
                default = "claude-opus-4-20250514",
            },
            -- extended_output = {
            --     condition = function(_self)
            --         return false
            --     end,
            -- },
            extended_thinking = {
                condition = function(_self)
                    return false
                end,
            },
            thinking_budget = {
                condition = function(_self)
                    return false
                end,
            },
        },
    } --[[@as Anthropic.Adapter]])
end
