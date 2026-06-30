do
    require("lib.pack")
    local progress = require("lib.pack.progress")

    -- Out-of-tree config layer managed by Nix/home-manager at ~/.config/nix/nvim.
    -- It's a local, non-git tree, so it can't go through vim.pack/zpack; wire it into the runtimepath manually.
    local nix = vim.fs.joinpath(nvim.file.xdg_config(), "nix", "nvim")

    if vim.uv.fs_stat(nix) then
        vim.opt.runtimepath:prepend(nix)

        -- Neovim only auto-derives the `after/` companion entry for the standard
        -- config dirs at startup. A dir added later gets none, so its after/lsp/*.lua
        -- would never be merged by vim.lsp.config. Append it so it sorts last in the
        -- after-group, giving these overrides precedence over ~/.config/nvim/after.
        if vim.uv.fs_stat(nix .. "/after") then
            vim.opt.runtimepath:append(nix .. "/after")
        end

        -- Newly added runtimepath entries are not auto-sourced
        -- (startup already enumerated plugin/), so source plugin/ scripts explicitly.
        for _, file in ipairs(vim.fn.globpath(nix .. "/plugin", "**/*.lua", false, true)) do
            vim.cmd.source(file)
        end
    end

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
