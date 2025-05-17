---@type LazySpec
return {
    ---@module "snacks"
    "folke/snacks.nvim",
    opts = {
        ---@type snacks.dashboard.Config
        dashboard = {
            enabled = true,
            formats = {
                icon = function(item)
                    if item.file and item.icon == "file" or item.icon == "directory" then
                        return Snacks.dashboard.icon(item.file, item.icon)
                    end

                    local icon_to_hl = {
                        ["󰁯 "] = "String",
                        [" "] = "@comment.todo",
                        [" "] = "Keyword",
                        [" "] = "@text.strong",
                    }

                    return { item.icon, width = 2, hl = icon_to_hl[item.icon] or "icon" } --[[@as snacks.dashboard.Text]]
                end,
                footer = { "%s", align = "center" },
                header = { "%s", align = "center" },
                ---@param item snacks.dashboard.Item
                ---@param ctx snacks.dashboard.Format.ctx
                file = function(item, ctx)
                    local fname = vim.fs.relpath(vim.env.HOME, item.file) or item.file

                    fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname

                    if #fname > ctx.width then
                        ---@type string?
                        local dir = vim.fs.dirname(fname)

                        ---@type string?
                        local file = vim.fs.basename(fname)

                        if dir and file then
                            file = file:sub(-(ctx.width - #dir - 2))
                            fname = dir .. "/…" .. file
                        end
                    end

                    return { fname }
                end,
            },
            preset = {
                ---@type snacks.dashboard.Item[]|fun(items:snacks.dashboard.Item[]):snacks.dashboard.Item[]?
                keys = {
                    { icon = "󰁯 ", key = "l", desc = "Load Session", action = ":SessionLoad", label = "[l]" },
                    { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert", label = "[n]" },
                    {
                        icon = "󰱼 ",
                        key = "f",
                        desc = "Find File",
                        action = ":lua Snacks.dashboard.pick('smart', { multi = { 'git_files', 'files' } })",
                        label = "[f]",
                    },
                    { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('grep')", label = "[g]" },
                    { icon = " ", key = "p", desc = "Profile Plugins", action = ":Lazy profile", enabled = package.loaded.lazy ~= nil, label = "[p]" },
                    { icon = " ", key = "u", desc = "Update Plugins", action = ":Lazy sync", enabled = package.loaded.lazy ~= nil, label = "[u]" },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa!", label = "[q]" },
                },
                pick = "snacks",
            },
            sections = {
                function()
                    -- In an initialized but empty / no commits repo,
                    -- there will be an error thrown to stderr from git-dashboard-nvim.
                    if not Snacks.git.get_root(vim.uv.cwd()) then
                        return {}
                    end

                    local heatmap = require("git-dashboard-nvim").heatmap()

                    -- Trigger git-dashboard's highlighting
                    ev.emit(ev.FileType, { pattern = "dashboard" })

                    return {
                        align = "left",
                        height = 12,
                        padding = 1,
                        text = { table.concat(heatmap, "\n") },
                    }
                end,
                {
                    align = "center",
                    text = { "[ Recent Files ]", hl = "Function" } --[[@as snacks.dashboard.Text]],
                    padding = 1,
                },
                { section = "recent_files", indent = 1, padding = 1 },
                {
                    align = "center",
                    text = { string.rep("─", 50), hl = "FloatBorder" } --[[@as snacks.dashboard.Text]],
                    padding = 1,
                },
                { section = "keys", indent = 1 },
                {
                    align = "center",
                    text = { string.rep("─", 50), hl = "FloatBorder" } --[[@as snacks.dashboard.Text]],
                    padding = 1,
                },
                { section = "startup" },
            },
            width = 80,
        },
    },
}
