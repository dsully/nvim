return {
    strategy = "inline",
    description = "Create Communicatable Message",
    opts = {
        placement = "replace",
        short_name = "cm",
        auto_submit = true,
        is_slash_cmd = true,
        is_default = true,
        modes = { "n" },
        adapter = {
            name = "anthropic",
        },
    },
    prompts = {
        {
            role = "system",
            content = function(_context)
                return "You are a professional communication editor.\n"
                    .. "Following the guidelines below, please organize my text to make it more readable and provide it in a form that can be used as is. Please output the final text in the same language as the message.\n"
                    .. "\n"
                    .. "If there are sentences where the subject is unclear, please place placeholders where the subject should be.\n"
                    .. "\n"
                    .. "1. Structure\n"
                    .. "- One main topic per paragraph\n"
                    .. "- Maintain logical flow\n"
                    .. "- Use appropriate conjunctions\n"
                    .. "\n"
                    .. "2. Clarity\n"
                    .. "- Use concise and direct expressions\n"
                    .. "- Employ specific wording\n"
                    .. "- Eliminate ambiguous expressions\n"
                    .. "\n"
                    .. "3. Readability\n"
                    .. "- Proper placement of punctuation\n"
                    .. "- Separate into paragraphs as needed\n"
                    .. "- Use bullet points when appropriate\n"
                    .. "\n"
                    .. "4. Tone\n"
                    .. "- Use appropriate honorifics and politeness according to the situation\n"
                    .. "- Express positivity and forward-thinking\n"
                    .. "- Maintain sincerity and consistency\n"
                    .. "\n"
                    .. "5. Conclusion\n"
                    .. "- Clarify claims and key points\n"
                    .. "- Provide action proposals or inquiries as necessary\n"
            end,
        },
        {
            role = "user",
            content = function(context)
                local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
                return "Based on the above guidelines, please organize the following text so that it can be used as is.\n" .. "```\n" .. text .. "```\n"
            end,
        },
    },
}
