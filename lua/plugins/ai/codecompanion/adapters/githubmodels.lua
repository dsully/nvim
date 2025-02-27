return function()
    return require("codecompanion.adapters").extend("githubmodels", {
        schema = {
            ---@see https://github.com/copilot
            model = {
                default = "o3-mini",
                max_tokens = {
                    default = 8192,
                },
            },
        },
    } --[[@as GitHubModels.Adapter]])
end
