return function()
    return require("codecompanion.adapters").extend("ollama", {
        env = {
            url = vim.env.OLLAMA_URL,
        },
        schema = {
            model = {
                default = "mistral",
            },
        },
        num_ctx = {
            default = 32768,
        },
    } --[[@as Ollama.Adapter]])
end
