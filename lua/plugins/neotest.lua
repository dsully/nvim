return {
    "nvim-neotest/neotest",
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-python")({
                    dap = { justMyCode = false },
                    -- Use whatever Python is on the path from the virtualenv.
                    python = "python3",
                    runner = "pytest",
                    args = {
                        "--log-level",
                        "DEBUG",
                        "-vv",
                    },
                }),
                require("neotest-rust"),
            },
        })
    end,
    dependencies = {
        "nvim-neotest/neotest-python",
        "rouge8/neotest-rust",
    },
    keys = {
        {
            "<leader>tf",
            function()
                require("neotest").run.run(vim.fn.expand("%s"))
            end,
            desc = "Run all tests in this file.",
        },
        {
            "<leader>ts",
            function()
                require("neotest").summary.toggle()
            end,
            desc = "Toggle the summary window.",
        },
        {
            "<leader>tt",
            function()
                require("neotest").run.run()
            end,
            desc = "Run the nearest test.",
        },
        {
            "<leader>tx",
            function()
                require("neotest").run.stop()
            end,
            desc = "Stop the test.",
        },
        {
            "<leader>td",
            function()
                require("neotest").run.run({ strategy = "dap" })
            end,
            desc = "Debug the nearest test function.",
        },
    },
}
