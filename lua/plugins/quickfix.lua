---@type LazySpec[]
return {
    {
        "stevearc/quicker.nvim",
        ft = "qf",
        init = function()
            require("which-key").add({
                {
                    "<leader>q",
                    function()
                        require("quicker").toggle()
                    end,
                    desc = "Toggle QuickFix list",
                    icon = defaults.icons.misc.quickfix,
                },
            })
        end,
        ---@module "quicker"
        ---@type quicker.SetupOptions
        opts = {
            borders = { vert = " " },
            highlight = {
                load_buffers = true,
            },
            max_filename_width = function()
                return math.floor(math.min(95, vim.o.columns / 2))
            end,
            opts = {
                winhighlight = "CursorLine:Visual,Delimiter:WinSeparator",
            },
        },
    },
}
