return {
    description = "Add documentation to the selected code",
    strategy = "inline",
    opts = {
        auto_submit = true,
        is_slash_cmd = true,
        modes = { "v" },
        short_name = "doc",
        stop_context_insertion = true,
        user_prompt = false,
    },
    prompts = {
        {
            role = "system",
            content = [[
                When asked to add documentation, follow these steps:
                1. **Identify Key Points**: Carefully read the provided code to understand its functionality.
                2. **Plan the Documentation**: Describe the key points to be documented in pseudocode, detailing each step.
                3. **Implement the Documentation**: Write the accompanying documentation in the same file or a separate file.
                4. **Review the Documentation**: Ensure that the documentation is comprehensive and clear. Ensure the documentation:
                  - Includes necessary explanations.
                  - Helps in understanding the code's functionality.
                  - Add parameters, return values, and exceptions documentation.
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

                return "Please document the selected code:\n\n```" .. context.filetype .. "\n" .. code .. "\n```\n\n"
            end,
            opts = {
                contains_code = true,
            },
        },
    },
}
