return {
    description = "Refactor the selected code for readability, maintainability and performance",
    strategy = "chat",
    opts = {
        auto_submit = true,
        is_slash_cmd = true,
        modes = { "v" },
        short_name = "refactor",
        stop_context_insertion = true,
        user_prompt = false,
    },
    prompts = {
        {
            role = "system",
            content = [[
                When asked to optimize code, follow these steps:
                1. **Analyze the Code**: Understand the functionality and identify potential bottlenecks.
                2. **Implement the Optimization**: Apply the optimizations including best practices to the code.
                3. **Shorten the code**: Remove unnecessary code and refactor the code to be more concise.
                3. **Review the Optimized Code**: Ensure the code is optimized for performance and readability. Ensure the code:
                  - Maintains the original functionality.
                  - Is more efficient in terms of time and space complexity.
                  - Follows best practices for readability and maintainability.
                  - Is formatted correctly.

                Use Markdown formatting and include the programming language name at the start of the code block.]],
            opts = {
                visible = false,
            },
        },
        {
            role = "user",
            content = function(context)
                local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                return "Please optimize the selected code:\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
            end,
            opts = {
                contains_code = true,
            },
        },
    },
}
