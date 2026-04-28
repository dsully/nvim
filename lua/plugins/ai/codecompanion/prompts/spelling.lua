return {
    description = "Correct grammar and reformulate",
    interaction = "inline",
    opts = {
        alias = "spell",
        auto_submit = true,
        is_slash_cmd = true,
        modes = { "v" },
    },
    prompts = {
        {
            role = "user",
            contains_code = false,
            content = function(context)
                local text = require("codecompanion.helpers.code").get_code(context.start_line, context.end_line)
                return "Correct grammar and reformulate:\n\n" .. text
            end,
        },
    },
}
