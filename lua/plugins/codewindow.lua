return {
    "gorbit99/codewindow.nvim",
    keys = {
        {
            "<leader>mm",
            function()
                require("codewindow").toggle_minimap()
            end,
            desc = "Toggle Minimap",
        },
    },
    opts = {
        auto_enable = true,
        exclude_filetypes = require("config.defaults").ignored.file_types,
        max_lines = 65536,
        minimap_width = 10,
    },
}
