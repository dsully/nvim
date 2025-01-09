return function()
    return require("codecompanion.adapters").extend("ollama", {
        env = {
            url = vim.env.OLLAMA_URL,
        },
        schema = {
            model = {
                default = "qwen2.5-coder:32b",
                -- choices = get_models(),
            },
        },
        num_ctx = {
            default = 32768,
        },
    } --[[@as Ollama.Adapter]])
end
