do
    require("lib.pack")
    local progress = require("lib.pack.progress")

    progress.setup()

    progress.with_pack_progress(function()
        progress.report_missing_lock_packs()

        vim.pack.add({ "https://github.com/zuqini/zpack.nvim" }, { confirm = false })

        -- Disable built-in plugins (was in lazy.nvim performance.rtp.disabled_plugins)
        local disabled = {
            "2html_plugin",
            "getscript",
            "getscriptPlugin",
            "gzip",
            "health",
            "logipat",
            "man",
            "matchit",
            "matchparen",
            "netrw",
            "netrwFileHandlers",
            "netrwPlugin",
            "netrwSettings",
            "rplugin",
            "rrhelper",
            "spellfile",
            "spellfile_plugin",
            "tar",
            "tarPlugin",
            "tohtml",
            "tutor",
            "vimball",
            "vimballPlugin",
            "zip",
            "zipPlugin",
            "plenary",
        }

        for _, name in ipairs(disabled) do
            vim.g["loaded_" .. name] = 1
        end

        -- Autocommands are a side-effect module (returns {}), require directly.
        require("config.autocommands")

        local spec = {
            { import = "plugins" },
            { import = "plugins.ai" },
            { import = "plugins.filetypes" },
            { import = "plugins.languages" },
            { import = "plugins.snacks" },
        }

        if vim.env.WORK ~= nil then
            spec[#spec + 1] = { import = "plugins.work" }
        end

        require("zpack").setup({
            defaults = {
                confirm = false,
                lazy = true,
            },
            spec = spec,
        })
    end)
end
