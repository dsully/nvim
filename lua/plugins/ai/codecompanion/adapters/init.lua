if defaults.work then
    return require("plugins.work.codecompanion.adapters")
else
    return {
        anthropic = require("plugins.ai.codecompanion.adapters.anthropic"),
        copilot = require("plugins.ai.codecompanion.adapters.copilot"),
        deepseek = require("plugins.ai.codecompanion.adapters.deepseek"),
        gemini = require("plugins.ai.codecompanion.adapters.gemini"),
        githubmodels = require("plugins.ai.codecompanion.adapters.githubmodels"),
        openai = require("plugins.ai.codecompanion.adapters.openai"),
        ollama = require("plugins.ai.codecompanion.adapters.ollama"),
        openrouter = require("plugins.ai.codecompanion.adapters.openrouter"),
        qwen25 = require("plugins.ai.codecompanion.adapters.qwen"),
    }
end
