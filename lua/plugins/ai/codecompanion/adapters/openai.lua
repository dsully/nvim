return function()
    return require("codecompanion.adapters").extend("openai", {
        schema = {
            ---@see https://platform.openai.com/docs/models
            model = {
                default = function()
                    return "o1-preview"
                end,
            },
        },
    } --[[@as OpenAI.Adapter]])
end
