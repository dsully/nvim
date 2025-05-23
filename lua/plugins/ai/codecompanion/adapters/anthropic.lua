return function()
    return require("codecompanion.adapters").extend("anthropic", {
        schema = {
            ---@see https://docs.anthropic.com/en/docs/about-claude/models
            model = {
                default = "claude-opus-4-20250514",
            },
        },
    } --[[@as Anthropic.Adapter]])
end
