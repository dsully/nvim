return {
    "nvim-lualine/lualine.nvim",
    config = function()
        local MODES = {
            ["n"] = "N",
            ["no"] = "N",
            ["nov"] = "N",
            ["noV"] = "N",
            ["no"] = "N",
            ["niI"] = "N",
            ["niR"] = "N",
            ["niV"] = "N",
            ["v"] = "V",
            ["V"] = "V",
            [""] = "V",
            ["s"] = "S",
            ["S"] = "S",
            [""] = "S",
            ["i"] = "I",
            ["ic"] = "I",
            ["ix"] = "I",
            ["R"] = "R",
            ["Rc"] = "R",
            ["Rv"] = "R",
            ["Rx"] = "R",
            ["r"] = "R",
            ["rm"] = "R",
            ["r?"] = "R",
            ["c"] = "C",
            ["cv"] = "C",
            ["ce"] = "C",
            ["!"] = "T",
            ["t"] = "T",
            ["nt"] = "T",
        }

        local WORDCOUNT = {
            markdown = true,
            text = true,
            vimwiki = true,
        }

        local empty = require("lualine.component"):extend()

        function empty:draw(default_highlight)
            self.status = ""
            self.applied_separator = ""
            self:apply_highlights(default_highlight)
            self:apply_section_separators()
            return self.status
        end

        local WHITE = "#ECEFF4"

        -- Put proper separators and gaps between components in sections
        local function process_sections(sections)
            for name, section in pairs(sections) do
                local left = name:sub(9, 10) < "x"
                for pos = 1, name ~= "lualine_z" and #section or #section - 1 do
                    table.insert(section, pos * 2, { empty, color = { fg = WHITE, bg = WHITE } })
                end
                for id, comp in ipairs(section) do
                    if type(comp) ~= "table" then
                        comp = { comp }
                        section[id] = comp
                    end
                    comp.separator = left and { right = "" } or { left = "" }
                end
            end
            return sections
        end

        -- Performance: We don't need this lualine require madness.
        local lualine_require = require("lualine_require")
        lualine_require.require = require

        require("lualine").setup({
            options = {
                disabled_filetypes = require("config.defaults").ignored.file_types,
                theme = "nord",
                component_separators = "",
                section_separators = { left = "", right = "" },
                globalstatus = true,
            },
            sections = process_sections({
                lualine_a = {
                    -- Display the mode icon.
                    function()
                        return MODES[vim.api.nvim_get_mode().mode]
                    end,
                },
                lualine_b = {
                    { "filetype" },
                    { "diagnostics", sources = { "nvim_diagnostic" } },
                },
                lualine_c = {
                    {
                        function()
                            if vim.v.hlsearch == 0 then
                                return ""
                            end
                            local last_search = vim.fn.getreg("/")
                            if not last_search or last_search == "" then
                                return ""
                            end
                            local searchcount = vim.fn.searchcount({ maxcount = 9999 })
                            return last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
                        end,
                    },
                    {
                        function()
                            return require("nvim-navic").get_location()
                        end,
                        cond = function()
                            return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
                        end,
                    },
                },
                lualine_x = {
                    function()
                        if vim.g.persisting then
                            return "󰅠 "
                        end
                        return "󰅣 "
                    end,
                    {
                        function()
                            local status = require("copilot.api").status.data
                            return " " .. (status.message or "")
                        end,
                        cond = function()
                            return #vim.lsp.get_clients({ name = "copilot", bufnr = 0 }) > 0
                        end,
                        color = function()
                            local function highlight(name)
                                ---@type {fg?:number}?
                                local hl = vim.api.nvim_get_hl(0, { name = name })
                                local fg = hl and hl.fg
                                return fg and { fg = string.format("#%06x", fg) }
                            end

                            local colors = {
                                [""] = highlight("Special"),
                                ["Normal"] = highlight("Special"),
                                ["Warning"] = highlight("DiagnosticError"),
                                ["InProgress"] = highlight("DiagnosticWarn"),
                            }

                            if package.loaded["copilot"] then
                                return colors[require("copilot.api").status.data.status] or colors[""]
                            end

                            return colors[""]
                        end,
                    },
                    {
                        function()
                            local space = vim.fn.search([[\s\+$]], "nwc")
                            return space ~= 0 and "TW:" .. space or ""
                        end,
                        cond = function()
                            local disable = {
                                help = true,
                                log = true,
                            }
                            return disable[vim.bo.filetype] == nil and not vim.bo.readonly and vim.bo.modifiable
                        end,
                    },
                    {
                        function()
                            return "Words: " .. vim.fn.wordcount()["words"]
                        end,
                        cond = function()
                            return WORDCOUNT[vim.bo.filetype] ~= nil
                        end,
                    },
                },
                lualine_y = {
                    "%l:%c",
                    "%p%% / %L ",
                },
                lualine_z = {
                    {
                        vim.g.gitsigns_head,
                        icon = "",
                    },
                },
            }),
            tabline = {},
            extensions = { "quickfix" },
        })
    end,
    enable = false,
}
