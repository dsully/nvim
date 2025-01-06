return {
    "williamboman/mason.nvim",
    cmd = {
        "Mason",
        "MasonInstall",
        "MasonUninstall",
        "MasonUpdate",
        "MasonToolsInstall",
        "MasonToolsUpdate",
    },
    config = function(_, opts)
        require("mason").setup(opts)

        vim.defer_fn(function()
            local mr = require("mason-registry")

            vim.iter(opts.ensure_installed):each(function(tool)
                local p = mr.get_package(tool)

                if p:is_installed() then
                    return
                end

                notify.info(("Installing %s"):format(p.name), { title = "Mason", render = "compact" })

                local handle_closed = vim.schedule_wrap(function()
                    if p:is_installed() then
                        notify.info(("Successfully installed %s"):format(p.name), { title = "Mason", render = "compact" })

                        -- Trigger FileType event to possibly load this newly installed LSP server
                        vim.defer_fn(function()
                            require("lazy.core.handler.event").trigger({
                                buf = vim.api.nvim_get_current_buf(),
                                event = ev.FileType,
                            })
                        end, 100)
                    end
                end)

                p:install():once("closed", handle_closed)
            end)
        end, 5000)
    end,
    event = ev.LazyFile,
    opts = {
        ---@type string[]
        ensure_installed = defaults.tools,
        registries = {
            "github:nvim-java/mason-registry",
            "github:mason-org/mason-registry",
            "github:mkindberg/ghostty-ls",
        },
        ui = {
            border = defaults.ui.border.name,
        },
    },
}
