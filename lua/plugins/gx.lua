---@type LazySpec
return {
    "chrishrb/gx.nvim",
    cmd = { "Browse" },
    keys = {
        -- stylua: ignore
        { "gx", function() require("gx").open() end, mode = { "n", "x" } },
    },
    submodules = false,
    ---@module "gx.nvim"
    ---@type GxOptions
    opts = {
        open_browser_app = "open",
        open_browser_args = { "--background" },
        handlers = {
            commit = true,
            github = true,
            go = true,
            markdown = true,
            nix = {
                filetype = { "nix" },
                handle = function(mode, line, _)
                    local find = require("gx.helper").find
                    local user = find(line, mode, "github:(.-)/.*") --[[@as string?]]
                    local repo = find(line, mode, 'github:.-/([%w_-]+)"?.*') --[[@as string?]]

                    if user and repo then
                        return ("https://github.com/%s/%s"):format(user, repo)
                    end
                end,
                name = "nix",
            },
            package_json = true, -- open dependencies from package.json
            plugin = true,
            rust = {
                name = "rust",
                filename = "Cargo.toml",
                handle = function(mode, line, _)
                    local crate = require("gx.helper").find(line, mode, "(%w+)%s-=%s")

                    if crate then
                        return "https://crates.io/crates/" .. crate
                    end
                end,
            },
            search = true,
            -- Until https://github.com/chrishrb/gx.nvim/issues/77 is addressed.
            url = {
                name = "url",
                filename = nil,
                filetype = nil,
                handle = function(mode, line, _)
                    return require("gx.helper").find(line, mode, "(https?://[a-zA-Z%d_/%%%-%.~@\\+#=?&:]+)")
                end,
            },
        },
        handler_options = {
            search_engine = "https://kagi.com/search?q=", -- or you can pass in a custom search engine
        },
    },
}
