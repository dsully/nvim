---@type LazySpec
return {
    "jmbuhr/otter.nvim",
    keys = {
        {
            "<leader>os",
            function()
                require("otter").activate()
            end,
            desc = "Otter Activate",
        },
    },
    ft = {
        "just",
        "markdown",
        "nix",
    },
    event = ev.VeryLazy,
    opts = {
        lsp = {
            root_dir = function(_, bufnr)
                return vim.fs.root(bufnr or 0, {
                    ".git",
                    "flake.nix",
                    "Justfile",
                    "package.json",
                    "pyproject.toml",
                }) or vim.fn.getcwd(0)
            end,
        },
        -- Add event listeners for LSP events for debugging
        -- debug = true,
        -- verbose = { -- set to false to disable all verbose messages
        --     no_code_found = true, -- warn if otter.activate is called, but no injected code was found
        -- },
    },
}
