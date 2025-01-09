return {
    strategy = "inline",
    description = "Generate a docstring for this function",
    opts = {
        modes = { "v" },
        short_name = "docstring",
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
                    .. " developer. I will send you a function and I want you to generate the docstrings for the function using the numpy format. Generate only the docstrings and nothing more. Put the generated docstring at the correct position in the code. Use tabs instead of spaces"
            end,
        },
        {
            role = "user",
            content = function(context)
                return require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
            end,
            opts = {
                visible = false,
                placement = "add",
                contains_code = true,
            },
        },
    },
}
