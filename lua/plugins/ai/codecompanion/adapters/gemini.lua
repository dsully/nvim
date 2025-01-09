return function()
    return require("codecompanion.adapters").extend("gemini", {
        schema = {
            ---@see https://ai.google.dev/gemini-api/docs/models/gemini
            model = {
                default = "gemini-2.0-flash-exp",
                choices = { "gemini-2.0-flash-exp", "gemini-1.5-pro" },
            },
        },
    } --[[@as Gemini.Adapter]])
end
