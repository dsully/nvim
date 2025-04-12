return function()
    return require("codecompanion.adapters").extend("gemini", {
        schema = {
            ---@see https://ai.google.dev/gemini-api/docs/models/gemini
            model = {
                default = "gemini-2.5-pro-preview-03-25",
            },
        },
    } --[[@as Gemini.Adapter]])
end
