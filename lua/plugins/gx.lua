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
            brewfile = true,
            commit = true,
            github = true,
            go = true,
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
            search = true,
        },
        handler_options = {
            search_engine = "https://kagi.com/search?q=", -- or you can pass in a custom search engine
        },
    },
}
