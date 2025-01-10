---@type LazySpec[]
return {
    {
        "nvim-neotest/neotest",
        highlights = {
            NeotestAdapterName = { bold = true, fg = colors.magenta.base },
            NeotestDir = { fg = colors.cyan.base },
            NeotestExpandMarker = { link = "Conceal" },
            NeotestFailed = { fg = colors.red.base },
            NeotestFile = { fg = colors.blue.base },
            NeotestFocused = { underline = true },
            NeotestIndent = { link = "Conceal" },
            NeotestMarked = { bold = true, fg = colors.white.dim },
            NeotestNamespace = { fg = colors.cyan.base },
            NeotestPassed = { fg = colors.green.base },
            NeotestRunning = { fg = colors.orange.base },
            NeotestSkipped = { fg = colors.yellow.base },
            NeotestTest = { link = "Normal" },
        },
        --stylua: ignore
        keys = {
            { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%s")) end, desc = "Run all tests in this file." },
            { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle the summary window." },
            { "<leader>tt", function() require("neotest").run.run() end, desc = "Run the nearest test." },
            { "<leader>tx", function() require("neotest").run.stop() end, desc = "Stop the test." },
        },
        opts = function()
            return {
                adapters = {
                    require("neotest-python")({
                        -- Use whatever Python is on the path from the virtualenv.
                        python = "python3",
                        runner = "pytest",
                        args = {
                            "-s", -- don't capture console output
                            "--log-level",
                            "DEBUG",
                            "-vv",
                        },
                        pytest_discover_instances = true, -- experimental, support parametrized test cases
                    }),
                    require("neotest-rust"),
                },
            }
        end,
    },
    { "nvim-neotest/neotest-python" },
    { "nvim-neotest/nvim-nio" },
    { "rouge8/neotest-rust" },
}
