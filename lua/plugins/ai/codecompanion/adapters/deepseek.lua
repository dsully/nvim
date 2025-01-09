return function()
    return require("codecompanion.adapters").extend("ollama", {
        name = "deepseek_coder",
        env = {
            url = vim.env.OLLAMA_URL,
        },
        num_ctx = {
            default = 32768,
        },
        schema = {
            model = {
                default = "deepseek-coder-v3:latest",
            },
        },
    } --[[@as Ollama.Adapter]])
end
