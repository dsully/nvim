local pickers = require("helpers.picker")
local pick = pickers.pick

return {
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        keys = {
            { "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
            { "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },

            { "<leader>f/", pickers.grep_curbuf_cword, desc = "Current Buffer <cword>" },
            { "<leader>f;", pick("resume"), desc = "Resume Picker" },
            { "<leader>fb", pick("buffers"), desc = "Buffer Picker" },
            { "<leader>fC", pick("git_bcommits", require("helpers.lsp").find_root), desc = "Buffer Commits" },
            { "<leader>fD", pick("diagnostics_document"), desc = "Diagnostics: Document" },
            { "<leader>fG", pick("git_files", require("helpers.lsp").find_root), desc = "Git Files" },
            -- { "<leader>fS", pick("lsp_dynamic_workspace_symbols"), desc = "Symbols: Workspace" },
            { "<leader>fc", pick("git_commits", require("helpers.lsp").find_root), desc = "Git Commits" },
            { "<leader>fd", pick("diagnostics_workspace"), desc = "Diagnostics: Workspace" },
            { "<leader>ff", pick("files", require("helpers.lsp").find_root), desc = "Files" },
            { "<leader>fg", pick("live_grep", require("helpers.lsp").find_root), desc = "Live Grep" },
            { "<leader>fk", pick("keymaps"), desc = "Key Maps" },
            { "<leader>fo", pick("oldfiles"), desc = "Recently Opened" },
            { "<leader>fq", pick("quickfix"), desc = "Quickfix List" },
            { "<leader>fw", pick("grep_cword"), desc = "Words" },

            { "<leader>fn", pickers.notifications, desc = "Notifications" },

            { "<leader>fP", pickers.parents, desc = "Parent dirs" },
            { "<leader>fR", pickers.repositories, desc = "Repositories" },
            { "<leader>fS", pickers.subdirectory, desc = "Subdirectories" },

            { "<leader>f.", pick("files", vim.env.XDG_CONFIG_HOME), desc = "dotfiles" },
            { "<leader>fp", pick("files", require("lazy.core.config").options.root), desc = "Plugins" },

            { "gD", pick("lsp_typedefs"), desc = "Goto Type Definition" },
            { "gd", pick("lsp_definitions", nil, { unique_line_items = true }), desc = "Goto Definition" },
            { "gi", pick("lsp_implementations"), desc = "Goto Implementation" },
            { "gi", pick("lsp_implementations"), desc = "Goto Implementation" },
            { "grr", pick("lsp_references"), desc = "References", nowait = true },
            { "gO", pick("lsp_document_symbols"), desc = "Symbols: Document" },
            { "z=", pick("spell_suggest"), desc = "Suggest Spelling" },
        },
        config = function(_, opts)
            local config = require("fzf-lua.config")
            local fzf = require("fzf-lua")

            -- Quickfix
            config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
            config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
            config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
            config.defaults.keymap.fzf["ctrl-x"] = "jump"
            config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
            config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
            config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
            config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

            -- Toggle root dir / cwd
            config.defaults.actions.files["ctrl-r"] = {
                fn = function(_, ctx)
                    local cwd = vim.uv.cwd()
                    local root = require("helpers.lsp").find_root(ctx.bufnr)

                    fzf.resume({
                        cwd = ctx.cwd ~= root and root or cwd,
                    })
                end,
            }

            -- Add the prompt back to the default-title profile
            local function add_prompt(t)
                t.prompt = t.prompt ~= nil and " " or t.prompt

                for _, v in pairs(t) do
                    if type(v) == "table" then
                        add_prompt(v)
                    end
                end

                return t
            end

            -- Lazy load nvim-treesitter or help files err with: Query error at 2:4. Invalid node type "delimiter"
            -- This is due to fzf-lua calling `vim.treesitter.language.add` before nvim-treesitter is loaded
            pcall(require, "nvim-treesitter")

            -- Require markview.nvim for previewer rendering.
            pcall(require, "markview")

            fzf.setup(vim.tbl_deep_extend("force", add_prompt(require("fzf-lua.profiles.default-title")), opts))

            -- register fzf-lua as vim.ui.select interface
            fzf.register_ui_select(function(o, items)
                --
                local winopts = {
                    title = " " .. vim.trim((o.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",

                    -- height is number of items, with a max of 80% screen height
                    height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5) + 1,
                    width = 0.7,
                }

                if o.kind == "codeaction" then
                    winopts = vim.tbl_deep_extend("force", winopts, {
                        -- height is number of items minus 18 lines for the preview, with a max of 80% screen height
                        height = math.floor(math.min(vim.o.lines * 0.8 - 18, #items + 2) + 0.5) + 18,
                        preview = {
                            layout = "vertical",
                            vertical = "down:15,border-top",
                        },
                    })
                end

                if o.kind ~= "codeaction" or o.kind ~= "codecompanion.nvim" then
                    -- Auto-width
                    local min_w, max_w = 0.05, 0.80
                    local longest = 0

                    for _, e in ipairs(items) do
                        -- Format the item or convert it to a string
                        local format_entry = o.format_item and o.format_item(e) or tostring(e)
                        local length = #format_entry

                        if length > longest then
                            longest = length
                        end
                    end

                    -- Needs minimum 7 in my case due to the extra stuff fzf adds on the left side (markers, numbers, extra padding, etc).
                    local w = math.min(math.max((longest + 9) / vim.o.columns, min_w), max_w)

                    winopts = vim.tbl_deep_extend("force", winopts, { winopts = { width = w } })
                end

                return { winopts = winopts }
            end)
        end,
        init = function()
            hl.apply({
                { FzfLuaPathColNr = { fg = colors.gray.base } },
                { FzfLuaPathLineNr = { fg = colors.gray.base } },
                { FzfLuaBorder = { link = "FloatBorder" } },
                { FzfLuaBackdrop = { fg = colors.none, bg = colors.black.dim } },
                { FzfLuaBufName = { fg = colors.cyan.bright, bg = colors.black.dim } },
                { FzfLuaBufNr = { fg = colors.cyan.base, bg = colors.black.dim } },
                { FzfLuaFzfGutter = { fg = colors.black.base, bg = colors.black.dim } },
                { FzfLuaHeaderBind = { fg = colors.green.base, bg = colors.black.dim } },
                { FzfLuaHeaderText = { fg = colors.cyan.bright, bg = colors.black.dim } },
                { FzfLuaTabMarker = { fg = colors.yellow.base, bg = colors.black.dim } },
            })
        end,
        opts = {
            defaults = {
                cwd_header = true,
                file_icons = "mini",
                formatter = "path.dirname_first",
                headers = { "actions", "cwd" },
                no_header_i = true, -- hide interactive header
            },
            file_icon_padding = " ",
            file_ignore_patterns = defaults.files.ignored_patterns,
            files = {
                cwd_prompt = false,
                resume = true,
            },
            fzf_colors = {
                bg = { "bg", "Normal" },
                gutter = { "bg", "Normal" },
                info = { "fg", "Conditional" },
                scrollbar = { "bg", "Normal" },
                separator = { "fg", "Comment" },
            },
            fzf_opts = {
                ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-history",
                ["--layout"] = "reverse-list",
                ["--info"] = "default",
                ["--no-scrollbar"] = true,
                -- Disable fuzzy matching. I know. :)
                -- ["--exact"] = "",
            },
            git = {
                files = {
                    cmd = "git ls-files --others --cached --exclude-standard",
                    path_shorten = false,
                },
            },
            helptags = { previewer = "help_native" },
            keymap = {
                builtin = {
                    ["<c-/>"] = "toggle-help",
                    ["<c-e>"] = "toggle-preview",
                    ["<c-f>"] = "preview-page-down",
                    ["<c-b>"] = "preview-page-up",
                },
                fzf = {
                    ["esc"] = "abort",
                    ["ctrl-q"] = "select-all+accept",
                    ["ctrl-e"] = "toggle-preview",
                    ["ctrl-f"] = "preview-page-down",
                    ["ctrl-b"] = "preview-page-up",
                },
            },
            live_grep = {
                RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH,
                fzf_opts = { ["--keep-right"] = "" },
                resume = true,
            },
            lsp = {
                code_actions = {
                    previewer = "codeaction_native",
                    preview_pager = "delta --width=$COLUMNS --hunk-header-style='omit' --file-style='omit'",
                },
                cwd_only = false, -- LSP/diagnostics for cwd only?
                -- https://github.com/ibhagwan/fzf-lua/wiki#disable-or-hide-filename-fuzzy-search
                document_symbols = {
                    fzf_cli_args = "--nth 2..",
                },
                ignore_current_line = true,
                includeDeclaration = false,
                jump_to_single_result = true,
            },
            oldfiles = {
                include_current_session = true,
            },
            previewers = {
                bat = {
                    cmd = "bat",
                    args = "--style=plain --color=always",
                },
                builtin = {
                    -- https://github.com/ibhagwan/fzf-lua/discussions/1364
                    toggle_behavior = "extend",
                },
                extensions = {
                    ["png"] = "viu",
                    ["jpg"] = "viu",
                    ["jpeg"] = "viu",
                    ["gif"] = "viu",
                    ["webp"] = "viu",
                },
            },
            treesitter = true,
            -- https://github.com/ibhagwan/fzf-lua/issues/775
            winopts = {
                border = defaults.ui.border.name,
                height = 0.8,
                width = 0.8,
                row = 0.2, -- window row position (0=top, 1=bottom)
                col = 0.5, -- window col position (0=left, 1=right)
                layout = "vertical",
                preview = {
                    border = "border-sharp", -- equivalent to `fzf --preview=border-sharp`
                    default = "bat",
                    hidden = "nohidden",
                    layout = "vertical",
                    scrollbar = false,
                    vertical = "up:50%",
                },
            },
        },
    },
    {
        "ziontee113/icon-picker.nvim",
        cmd = { "IconPickerNormal", "IconPickerYank", "IconPickerInsert" },
        keys = {
            { "<leader>fe", "<cmd>IconPickerInsert emoji<cr>", desc = "Emoji" },
            { "<leader>fi", "<cmd>IconPickerInsert nerd_font_v3<cr>", desc = "Nerd Font Icons" },
        },
        opts = {
            disable_legacy_commands = true,
        },
    },
    {
        "SmiteshP/nvim-navic",
        event = ev.LazyFile,
        init = function()
            hl.apply({
                { NavicIconsArray = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsBoolean = { bg = colors.gray.base, fg = colors.orange.base } },
                { NavicIconsClass = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsConstant = { bg = colors.gray.base, fg = colors.orange.base } },
                { NavicIconsConstructor = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsEnum = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsEnumMember = { bg = colors.gray.base, fg = colors.cyan.base } },
                { NavicIconsEvent = { bg = colors.gray.base, fg = colors.magenta.base } },
                { NavicIconsField = { bg = colors.gray.base, fg = colors.blue.base } },
                { NavicIconsFile = { bg = colors.gray.base, fg = colors.blue.base } },
                { NavicIconsFunction = { bg = colors.gray.base, fg = colors.magenta.base } },
                { NavicIconsInterface = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsKey = { bg = colors.gray.base, fg = colors.magenta.base } },
                { NavicIconsMethod = { bg = colors.gray.base, fg = colors.magenta.base } },
                { NavicIconsModule = { bg = colors.gray.base, fg = colors.blue.base } },
                { NavicIconsNamespace = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsNull = { bg = colors.gray.base, fg = colors.red.base } },
                { NavicIconsNumber = { bg = colors.gray.base, fg = colors.orange.base } },
                { NavicIconsObject = { bg = colors.gray.base, fg = colors.orange.base } },
                { NavicIconsOperator = { bg = colors.gray.base, fg = colors.magenta.base } },
                { NavicIconsPackage = { bg = colors.gray.base, fg = colors.orange.base } },
                { NavicIconsProperty = { bg = colors.gray.base, fg = colors.blue.base } },
                { NavicIconsString = { bg = colors.gray.base, fg = colors.green.base } },
                { NavicIconsStruct = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsTypeParameter = { bg = colors.gray.base, fg = colors.yellow.base } },
                { NavicIconsVariable = { bg = colors.gray.base, fg = colors.blue.base } },
                { NavicSeparator = { bg = colors.gray.base, fg = colors.cyan.base } },
                { NavicText = { bg = colors.gray.base, fg = colors.white.base } },
            })

            vim.g.navic_silence = true
        end,
        opts = {
            highlight = true,
            lazy_update_context = true,
            lsp = {
                auto_attach = true,
                preference = { "basedpyright" },
            },
        },
    },
    {
        "folke/todo-comments.nvim",
        event = ev.LazyFile,
        -- stylua: ignore
        keys = {
            { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
            { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
            { "<leader>ft", function () require("todo-comments.fzf").todo() end, desc = "TODOs" },
        },
        opts = {
            highlight = {
                -- https://github.com/folke/todo-comments.nvim/pull/199
                keyword = "bg",
                pattern = [[.{-}<(\s?(KEYWORDS):)]],
                -- pattern = [[(KEYWORDS)\s*(\([^\)]*\))?:]],
            },
            keywords = {
                BUG = { icon = "🐛", color = "error", alt = { "BROKEN", "FIXME", "ISSUE" } },
                HACK = { icon = "🔥", color = "warning" },
                IDEA = { icon = "💡", color = "test" },
                NOTE = { icon = "ℹ️", color = "hint", alt = { "INFO" } },
                TEST = { icon = "🧪", color = "test", alt = { "EXPERIMENT", "TESTING" } },
                TODO = { icon = "✅", color = "info" },
                WARN = { icon = "⚠️", color = "warning", alt = { "WARNING", "XXX" } },
            },
        },
    },
    {
        "folke/trouble.nvim",
        cmd = { "Trouble" },
        keys = {
            -- stylua: ignore
            { "<leader>xx", function() require("trouble").toggle({ mode = "diagnostics" }) end, desc = "Trouble" },
        },
        opts = {
            auto_preview = false,
            focus = true,
            modes = {
                lsp_references = {
                    params = {
                        include_declaration = false,
                    },
                },
            },
        },
    },
    {
        "MagicDuck/grug-far.nvim",
        cmd = "GrugFar",
        keys = {
            {
                "<leader>s/",
                function()
                    local grug = require("grug-far")
                    local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")

                    grug.open({
                        transient = true,
                        prefills = {
                            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
                        },
                    })
                end,
                mode = { "n", "v" },
                desc = "Search and Replace",
            },
        },
        opts = {
            debounceMs = 500,
            engine = "astgrep",
            folding = {
                enabled = false,
            },
            headerMaxWidth = 80,
            maxWorkers = 10,
            minSearchChars = 2,
            startInInsertMode = false,
            windowCreationCommand = "split",
        },
    },
    {
        "echasnovski/mini.align",
        keys = {
            { "g=", desc = "mini.align: align", mode = { "n", "x" } },
            { "g+", desc = "mini.align: align with preview", mode = { "n", "" } },
        },
        opts = {
            mappings = {
                start = "g=",
                start_with_preview = "g+",
            },
        },
        virtual = true,
    },
}
