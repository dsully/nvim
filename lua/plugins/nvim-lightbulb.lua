return {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",
    init = function()
        vim.fn.sign_define("LightBulbSign", { text = "󰌶", texthl = "LspDiagnosticsDefaultInformation", linehl = "", numhl = "" })
    end,
    opts = {
        ignore = { "copilot" },
    },
}
