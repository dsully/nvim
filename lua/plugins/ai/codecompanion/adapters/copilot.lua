return function()
    return require("codecompanion.adapters").extend("copilot", {
        schema = {
            ---@see https://github.com/copilot
            model = {
                default = "o3-mini-2025-01-31",
                max_tokens = {
                    default = 8192,
                },
            },
        },
    } --[[@as Copilot.Adapter]])
end
