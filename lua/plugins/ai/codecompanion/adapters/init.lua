if defaults.work then
    --
    if vim.env.WORK_NVIM == nil then
        vim.notify("WORK is set, but WORK_NVIM is not set or invalid.", vim.log.levels.ERROR, {
            title = "CodeCompanion",
        })
        return {}
    end

    local status, chunk = pcall(loadfile, vim.env.WORK_NVIM)

    if status and chunk then
        return chunk()
    end

    vim.notify("Loading from " .. vim.env.WORK_NVIM .. " failed!", vim.log.levels.ERROR, {
        title = "CodeCompanion",
    })

    return {}
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
