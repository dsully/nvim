---@module "overseer"
---@type overseer.TemplateFileDefinition
return {
    name = "uv",
    builder = function()
        ---@type overseer.TaskDefinition
        return {
            cmd = "uv",
            strategy = {
                "orchestrator",
                tasks = {
                    {
                        cmd = "uv lock",
                        components = {
                            {
                                "open_output",
                                direction = "dock",
                                focus = true,
                                on_start = "never",
                                on_complete = "failure",
                            },
                            "default",
                        },
                    },
                    {
                        cmd = "uv sync",
                        components = {
                            {
                                "open_output",
                                direction = "dock",
                                focus = true,
                                on_start = "never",
                                on_complete = "failure",
                            },
                            "default",
                        },
                    },
                },
            },
            components = { "default" },
        }
    end,
    condition = {
        callback = function()
            return nvim.file.stem(nvim.file.filename()) == "pyproject.toml" and vim.uv.fs_stat("uv.lock") ~= nil
        end,
        filetype = { "toml" },
    },
}
