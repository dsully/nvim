local parsers = {
    "bash",
    "caddy",
    "css",
    "diff",
    "editorconfig",
    "fish",
    "git_config",
    "git_rebase",
    "gitcommit",
    "gitignore",
    "go",
    "html",
    "ini",
    "javascript",
    "json",
    "just",
    "lua",
    "markdown",
    "markdown_inline",
    "nix",
    "pkl",
    "python",
    "query",
    "regex",
    "rust",
    "toml",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
}

local wait = 60000 -- # ms

---@type zpack.Spec[]
return {
    {
        ---@module "nvim-treesitter"
        "nvim-treesitter/nvim-treesitter",
        build = function()
            -- Re-install (picks up any newly-added parsers from the list above)
            -- and update existing ones.
            require("nvim-treesitter").install(parsers):wait(wait)
            require("nvim-treesitter").update():wait(wait)
        end,
        init = function()
            -- Main-branch nvim-treesitter ships queries under `runtime/queries/`,
            -- which isn't on rtp by default. Prepend it so highlights/folds/indents
            -- are visible to `vim.treesitter.start`.
            local init = vim.api.nvim_get_runtime_file("lua/nvim-treesitter/init.lua", false)[1]

            if init then
                vim.opt.runtimepath:prepend(vim.fn.fnamemodify(init, ":h:h:h") .. "/runtime")
            end

            local isnt_installed = function(p)
                return #vim.api.nvim_get_runtime_file("parser/" .. p .. ".*", false) == 0
            end

            local to_install = vim.tbl_filter(isnt_installed, parsers)

            if #to_install > 0 then
                -- Route per-parser install messages through Snacks notifier
                -- instead of nvim_echo which floods the screen with a split pager.
                local tlog = require("nvim-treesitter.log")
                local done = 0

                local installing = {} ---@type table<string, boolean>
                for _, l in ipairs(to_install) do
                    installing[l] = true
                end

                ---@diagnostic disable-next-line: duplicate-set-field
                tlog.Logger.info = function(self, m, ...)
                    local msg = m:format(...)
                    local lang = self.ctx and self.ctx:match("^install/(.+)$")

                    if not lang or not installing[lang] then
                        return
                    end

                    if msg == "Language installed" then
                        done = done + 1
                        msg = lang .. " installed"
                    end

                    vim.notify(string.format("%s (%d/%d)", msg, done, #to_install), vim.log.levels.INFO, {
                        id = "ts_install",
                        title = "nvim-treesitter",
                    })
                end

                require("nvim-treesitter").install(to_install):wait(wait)
            end

            local filetypes = {}

            for _, p in ipairs(parsers) do
                for _, ft in ipairs(vim.treesitter.language.get_filetypes(p)) do
                    table.insert(filetypes, ft)
                end
            end

            -- vim.highlight.priorities.semantic_tokens = 100
            -- vim.highlight.priorities.treesitter = 125

            local disabled_indent = { "yaml", "bash", "python" }

            ev.on(ev.FileType, function(event)
                --
                -- Parsers may not be installed yet (async install in progress).
                if not pcall(vim.treesitter.start, event.buf) then
                    return
                end

                if vim.tbl_contains(disabled_indent, event.filetype) then
                    vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end, {
                pattern = filetypes,
            })
        end,
        lazy = false,
        keys = {
            { "<leader>i", vim.cmd.Inspect, desc = "Inspect Position" },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = ev.LazyFile,
        init = function()
            vim.g.no_plugin_maps = true
        end,
    },
    {
        "maxbol/treesorter.nvim",
        cmd = "TSort",
        opts = {},
    },
    {
        "dsully/treesitter-jump.nvim",
        config = function()
            keys.map("%", require("treesitter-jump").jump)
        end,
        ft = {
            "lua",
            "python",
        },
    },
    {
        "folke/ts-comments.nvim",
        event = ev.LazyFile,
        opts = {},
    },
}
