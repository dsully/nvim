return function()
    return require("codecompanion.adapters").extend("gemini", {
        schema = {
            ---@see https://ai.google.dev/gemini-api/docs/models/gemini
            model = {
                default = "gemini-2.0-flash-exp",
            },
        },
    } --[[@as Gemini.Adapter]])
end
