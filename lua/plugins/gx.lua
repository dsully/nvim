---@type zpack.Spec
return {
    "chrishrb/gx.nvim",
    cmd = { "Browse" },
    keys = {
        -- stylua: ignore
        { "gx", function() require("gx").open() end, mode = { "n", "x" } },
    },
    ---@module "gx.nvim"
    ---@return GxOptions
    opts = function()
        ---@type GxOptions
        local options = {
            open_browser_app = "open",
            open_browser_args = { "--background" },
            select_prompt = false,
            handlers = {
                commit = true,
                github = true,
                go = true,
                markdown = true,
                nix = {
                    filetype = { "nix" },
                    handle = function(mode, line, _)
                        local find = require("gx.helper").find

                        -- Flake-style: github:owner/repo
                        local gh_user = find(line, mode, "github:([%w%._-]+)/[%w%._-]+") --[[@as string?]]
                        local gh_repo = find(line, mode, "github:[%w%._-]+/([%w%._-]+)") --[[@as string?]]

                        if gh_user and gh_repo then
                            return ("https://github.com/%s/%s"):format(gh_user, gh_repo)
                        end

                        -- Strip optional git+ prefix and trailing .git for the matchers below.
                        -- HTTPS with optional user info: [git+]https://[user@]host/owner/repo[.git]
                        local https_host, https_owner, https_repo = line:match('https?://[^/%s"]-@?([%w%.%-]+)/([%w%._-]+)/([%w%._-]+)')

                        if not https_host then
                            https_host, https_owner, https_repo = line:match("https?://([%w%.%-]+)/([%w%._-]+)/([%w%._-]+)")
                        end

                        if https_host and https_owner and https_repo then
                            return ("https://%s/%s/%s"):format(https_host, https_owner, https_repo:gsub("%.git$", ""))
                        end

                        -- SSH scheme: [git+]ssh://git@host[:port]/owner/repo[.git]
                        local ssh_host, ssh_owner, ssh_repo = line:match("ssh://[^@%s]+@([%w%.%-]+)[:/]([%w%._-]+)/([%w%._-]+)")

                        if ssh_host and ssh_owner and ssh_repo then
                            return ("https://%s/%s/%s"):format(ssh_host, ssh_owner, ssh_repo:gsub("%.git$", ""))
                        end

                        -- SCP-like SSH: git@host:owner/repo[.git]
                        local scp_host, scp_owner, scp_repo = line:match("git@([%w%.%-]+):([%w%._-]+)/([%w%._-]+)")

                        if scp_host and scp_owner and scp_repo then
                            return ("https://%s/%s/%s"):format(scp_host, scp_owner, scp_repo:gsub("%.git$", ""))
                        end
                    end,
                    name = "nix",
                },
                package_json = true, -- open dependencies from package.json
                plugin = true,
                pypi = {
                    name = "pypi",
                    filename = "pyproject.toml",
                    handle = function(mode, line, _)
                        -- Match poetry dependencies (name = "version")
                        local pkg = require("gx.helper").find(line, mode, "([^=%s]+)%s-=%s")
                        if pkg then
                            return "https://pypi.org/project/" .. pkg .. "/"
                        end
                        -- Match builtin dependencies list format ("name>=version" or "name")
                        local dep_pkg = require("gx.helper").find(line, mode, '"([^>=%s"]+)[^"]*"')
                        if dep_pkg then
                            return "https://pypi.org/project/" .. dep_pkg .. "/"
                        end
                    end,
                },
                python_pep = true,
                ruff = {
                    name = "ruff",
                    filetypes = { "python" },
                    handle = function(mode, line, _)
                        local rule = require("gx.helper").find(line, mode, "# noqa: ([A-Z][0-9]+)")
                        if rule then
                            return "https://docs.astral.sh/ruff/rules/" .. rule
                        end
                    end,
                },
                rust = {
                    name = "rust",
                    filename = "Cargo.toml",
                    handle = function(mode, line, _)
                        local crate = require("gx.helper").find(line, mode, "([^=%s]+)%s-=%s")

                        if crate then
                            return "https://crates.io/crates/" .. crate
                        end
                    end,
                },
                search = true,
            },
            handler_options = {
                search_engine = "https://kagi.com/search?q=", -- or you can pass in a custom search engine
            },
        }

        -- Merge out-of-tree, handlers registered by ~/.config/nix/nvim/plugin/gx_handlers.lua into _G.gx_local_handlers.
        for name, handler in pairs(_G.gx_local_handlers or {}) do
            options.handlers[name] = handler
        end

        return options
    end,
}
