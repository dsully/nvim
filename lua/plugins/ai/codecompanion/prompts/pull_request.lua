return {
    description = "Generate a Pull Request message description",
    strategy = "chat",
    opts = {
        auto_submit = true,
        is_slash_cmd = true,
        modes = { "n" },
        short_name = "pr",
    },
    prompts = {
        {
            role = "user",
            contains_code = true,
            content = function()
                return "You are an expert at writing detailed and clear pull request descriptions."
                    .. "Please create a pull request message following standard convention from the provided diff changes."
                    .. "Ensure the title, description, type of change, checklist, related issues, and additional notes sections are well-structured and informative."
                    .. "\n\n```diff\n"
                    .. vim.fn.system("git diff $(git merge-base HEAD origin)...HEAD")
                    .. "\n```"
            end,
        },
    },
}
