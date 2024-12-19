return {
    -- Log file syntax highlighting.
    { "fei6409/log-highlight.nvim", event = "BufRead *.log", opts = {} },

    -- Caddy
    { "isobit/vim-caddyfile", ft = "caddyfile" },
    { "https://github.com/Samonitari/tree-sitter-caddy", ft = "caddyfile" },

    -- Jinja
    { "geigerzaehler/tree-sitter-jinja2", ft = "jinja2" },

    -- C/C++
    { "p00f/clangd_extensions.nvim", enabled = false },

    -- For adding words to typos.toml
    { "vhyrro/toml-edit.lua", build = "rockspec", priority = 1000 },

    -- Better vim help.
    { "dsully/helpview.nvim", branch = "treesitter-compat", lazy = false },

    -- Apple's PKL language.
    {
        "apple/pkl-neovim",
        build = function()
            require("pkl-neovim.internal").init()

            -- Set up syntax highlighting.
            vim.cmd.TSInstall({ "pkl", bang = true })
        end,
        event = "BufReadPre *.pkl",
    },

    {
        "vuki656/package-info.nvim",
        config = function()
            local package = require("package-info")

            package.setup()

            keys.map("<leader>nu", package.update, "Package: Update package on line")
            keys.map("<leader>nd", package.delete, "Package: Delete package on line")
            keys.map("<leader>ni", package.install, "Package: Install new package")
            keys.map("<leader>nv", package.change_version, "Package: Change version of package on line")
        end,
        event = "BufRead package.json",
    },

    {
        "ghostty",
        cond = function()
            return vim.fn.executable("ghostty") == 1
        end,
        dir = "/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/",
        lazy = false,
    },
}
