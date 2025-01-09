return {
    description = "Correct grammar and reformulate",
    strategy = "inline",
    opts = {
        auto_submit = true,
        is_slash_cmd = true,
        modes = { "v" },
        short_name = "spell",
    },
    prompts = {
        {
            role = "user",
            contains_code = false,
            content = function(context)
                local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
                return "Correct grammar and reformulate:\n\n" .. text
            end,
        },
    },
}
