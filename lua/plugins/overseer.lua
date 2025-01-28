return {
    "stevearc/overseer.nvim",
    cmd = {
        "OverseerOpen",
        "OverseerToggle",
        "OverseerRun",
    },
    ---@module "overseer.config"
    ---@type overseer.Config
    opts = {
        templates = {
            "builtin",
            "python.uv",
        },
        task_list = {
            bindings = {
                ["<C-j>"] = false,
                ["<C-k>"] = false,
                ["<C-h>"] = false,
                ["<C-l>"] = false,
                ["<C-u>"] = "ScrollOutputUp",
                ["<C-d>"] = "ScrollOutputDown",
            },
            default_detail = 1,
            direction = "bottom",
            max_height = 25,
            min_height = 25,
        },
    },
}
