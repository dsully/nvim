return function()
    return require("codecompanion.adapters").extend("openai_compatible", {
        schema = {
            model = {
                default = "deepseek/deepseek-chat",
            },
            num_ctx = {
                default = 65536,
            },
        },
        -- headers = {
        --     ["HTTP-Referer"] = "https://x.com/0xWren",
        --     ["X-Title"] = "Wren",
        -- },
        env = {
            url = "https://openrouter.ai/api",
            chat_url = "/v1/chat/completions",
            api_key = "cmd:op read op://personal/OpenRouter/credential --no-newline",
        },
    } --[[@as OpenAI.Adapter]])
end
