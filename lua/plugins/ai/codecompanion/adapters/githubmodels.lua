return function()
    return require("codecompanion.adapters").extend("githubmodels", {
        schema = {
            ---@see https://github.com/copilot
            model = {
                default = "o3-mini",
                choices = { "o3-mini", "claude-3.5-sonnet" },
                max_tokens = {
                    default = 8192,
                },
            },
        },
    } --[[@as GitHubModels.Adapter]])
end
