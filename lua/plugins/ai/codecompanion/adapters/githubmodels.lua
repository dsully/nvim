return function()
    return require("codecompanion.adapters").extend("githubmodels", {
        schema = {
            ---@see https://github.com/copilot
            model = {
                default = "o3-mini",
            },
        },
    } --[[@as GitHubModels.Adapter]])
end
