return function()
    return require("codecompanion.adapters").extend("copilot", {
        schema = {
            ---@see https://github.com/copilot
            model = {
                default = "claude-3.7-sonnet",
            },
        },
    } --[[@as Copilot.Adapter]])
end
