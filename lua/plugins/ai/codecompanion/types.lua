---@class PromptMessage
---@field role string
---@field content function|table<string,any>
---@field opts? table<string,any>

---@class CodeCompanionPrompt
---@field strategy string
---@field description string
---@field opts table<string, any>
---@field prompts PromptMessage[]
