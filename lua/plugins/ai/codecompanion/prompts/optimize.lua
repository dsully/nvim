return {
    strategy = "inline",
    description = "Optimize the selected code",
    opts = {
        modes = { "v" },
        short_name = "optimize",
        index = 14,
        auto_submit = true,
        stop_context_insertion = true,
        user_prompt = false,
    },
    prompts = {
        {
            role = "system",
            content = function(context)
                return "I want you to act as a senior "
                    .. context.filetype
                    .. " developer."
                    .. " I will give code and I want you in response to return a code that can replace this code without any additional explanations or new comments. "
            end,
            opts = {
                visible = false,
            },
        },
        {
            role = "user",
            content = function(context)
                local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                return "Please optimize the following code:\n\n```" .. context.filetype .. "\n" .. text .. "\n```\n\n"
            end,
            opts = {
                contains_code = true,
            },
        },
    },
}
