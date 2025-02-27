return function()
    return require("codecompanion.adapters").extend("anthropic", {
        schema = {
            ---@see https://docs.anthropic.com/en/docs/about-claude/models
            model = {
                default = "claude-3-7-sonnet-20250219",
            },
        },
    } --[[@as Anthropic.Adapter]])
end
