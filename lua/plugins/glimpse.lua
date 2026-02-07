---@type LazySpec
return {
    "dsully/glimpse.nvim",
    virtual = true,
    keys = {
        --stylua: ignore start
        { "<leader>f/", function() require("glimpse.providers.files").grep_word({ dirs = { nvim.file.filename() } }) end, desc = "Buffer Word" },
        { "<leader>ff", function() require("glimpse.providers.files").files() end, desc = "Files" },
        { "<leader>fg", function() require("glimpse.providers.files").live_grep() end, desc = "Grep" },
        --stylua: ignore end
    },
}
