---@type LazySpec
return {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = {
        "Mason",
        "MasonInstall",
        "MasonUninstall",
        "MasonUpdate",
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
                        ev.emit(ev.FileType, { buffer = vim.api.nvim_get_current_buf(), modeline = false })
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
            "github:mason-org/mason-registry",
            "github:mkindberg/ghostty-ls",
        },
        ui = {
            border = defaults.ui.border.name,
        },
    },
}
