local actions = {
    ["alt-i"] = {
        fn = function(...)
            require("fzf-lua.actions").toggle_ignore(...)
        end,
    },
    ["alt-h"] = {
        fn = function(...)
            require("fzf-lua.actions").toggle_hidden(...)
        end,
    },
}

---@type LazySpec[]
return {
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        highlights = {
            FzfLuaPathColNr = { fg = colors.gray.base },
            FzfLuaPathLineNr = { fg = colors.gray.base },
            FzfLuaBorder = { link = "FloatBorder" },
            FzfLuaBackdrop = { fg = colors.none, bg = colors.black.dim },
            FzfLuaBufName = { fg = colors.cyan.bright, bg = colors.black.dim },
            FzfLuaBufNr = { fg = colors.cyan.base, bg = colors.black.dim },
            FzfLuaFzfGutter = { fg = colors.black.base, bg = colors.black.dim },
            FzfLuaHeaderBind = { fg = colors.green.base, bg = colors.black.dim },
            FzfLuaHeaderText = { fg = colors.cyan.bright, bg = colors.black.dim },
            FzfLuaTabMarker = { fg = colors.yellow.base, bg = colors.black.dim },
        },
        init = function()
            --
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.select = function(...)
                --
                -- register fzf-lua as vim.ui.select interface
                require("lazy").load({ plugins = { "fzf-lua" } })
                require("fzf-lua").register_ui_select(lazy.opts("fzf-lua").ui_select or nil)

                return vim.ui.select(...)
            end
        end,
        keys = function()
            --
            ---@param command string
            ---@param root boolean?
            ---@param opts table<string, any>?
            local pick = function(command, root, opts)
                return function()
                    --
                    local cwd = root and require("helpers.lsp").find_root() or nil

                    pcall(require("fzf-lua")[command], vim.tbl_deep_extend("force", opts or {}, { cwd = cwd }))
                end
            end

            -- stylua: ignore
            return {
                { "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
                { "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },

                { "<leader>f/", function() require("helpers.picker").grep_curbuf_cword() end, desc = "Current Buffer <cword>" },
                { "<leader>f;", pick("resume"), desc = "Resume Picker" },
                { "<leader>fb", pick("buffers"), desc = "Buffer Picker" },
                { "<leader>fC", pick("git_bcommits", true), desc = "Buffer Commits" },
                { "<leader>fD", pick("diagnostics_document"), desc = "Diagnostics: Document" },
                { "<leader>fG", pick("git_files", true), desc = "Git Files" },
                -- { "<leader>fS", pick("lsp_dynamic_workspace_symbols"), desc = "Symbols: Workspace" },
                { "<leader>fc", pick("git_commits", true), desc = "Git Commits" },
                { "<leader>fd", pick("diagnostics_workspace"), desc = "Diagnostics: Workspace" },
                { "<leader>ff", pick("files", true), desc = "Files" },
                { "<leader>fg", pick("live_grep", true), desc = "Live Grep" },
                { "<leader>fk", pick("keymaps"), desc = "Key Maps" },
                { "<leader>fo", pick("oldfiles"), desc = "Recently Opened" },
                { "<leader>fq", pick("quickfix"), desc = "Quickfix List" },
                { "<leader>fw", pick("grep_cword", true), desc = "Words" },
                { "<leader>fn", function() require("helpers.picker").notifications() end, desc = "Notifications" },
                { "<leader>fP", function() require("helpers.picker").parents() end, desc = "Parent dirs" },
                { "<leader>fR", function() require("helpers.picker").repositories() end, desc = "Repositories" },
                { "<leader>fS", function() require("helpers.picker").subdirectory() end, desc = "Subdirectories" },

                { "gD", pick("lsp_typedefs"), desc = "Goto Type Definition" },
                { "gd", pick("lsp_definitions", nil, { unique_line_items = true }), desc = "Goto Definition" },
                { "gi", pick("lsp_implementations"), desc = "Goto Implementation" },
                { "gi", pick("lsp_implementations"), desc = "Goto Implementation" },
                { "grr", pick("lsp_references"), desc = "References", nowait = true },
                { "gO", pick("lsp_document_symbols"), desc = "Symbols: Document" },
                { "z=", pick("spell_suggest"), desc = "Suggest Spelling" },
            }
        end,
        opts = {
            actions = {
                files = {
                    -- Inherit default bindings.
                    true,
                    -- Toggle root dir / cwd
                    ["ctrl-r"] = {
                        fn = function(_, ctx)
                            local cwd = vim.uv.cwd()
                            local root = require("helpers.lsp").find_root(ctx.bufnr)

                            require("fzf-lua").resume({
                                cwd = ctx.cwd ~= root and root or cwd,
                            })
                        end,
                    },
                    -- Open in Trouble
                    ["ctrl-t"] = {
                        fn = function(...)
                            return require("trouble.sources.fzf").open(...)
                        end,
                    },
                },
            },
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
                actions = actions,
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
                actions = actions,
                fzf_opts = { ["--keep-right"] = "" },
                glob_separator = "  ",
                resume = true,
                rg_glob = true,
                --- @param query string First returned string is the new search query
                --- @param opts table Second returned string are (optional) additional rg flags
                --- @return string, string?
                rg_glob_fn = function(query, opts)
                    ---@type string, string
                    local search_query, glob_args = query:match(("(.*)%s(.*)"):format(opts.glob_separator))

                    -- Uncomment to debug print into fzf
                    -- if glob_args then
                    --     io.write(("q: %s -> flags: %s, query: %s\n"):format(query, glob_args, search_query))
                    -- end

                    return search_query, glob_args
                end,
            },
            lsp = {
                code_actions = {
                    async_or_timeout = 5000,
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
                symbols = {
                    symbol_fmt = function(s)
                        return s:lower() .. "\t"
                    end,
                    symbol_hl = function(s)
                        return "TroubleIcon" .. s
                    end,
                    symbol_icons = defaults.icons.lsp,
                },
            },
            oldfiles = {
                cwd_only = true,
                include_current_session = true,
                stat_file = true,
            },
            previewers = {
                bat = {
                    cmd = "bat",
                    args = "--style=plain --color=always",
                },
                builtin = {
                    -- Don't syntax highlight files larger than 100KB
                    syntax_limit_b = 1024 * 100, -- 100KB
                    -- https://github.com/ibhagwan/fzf-lua/discussions/1364
                    toggle_behavior = "extend",
                    treesitter = {
                        enable = false,
                    },
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
            -- Custom option called via init()
            ui_select = function(opts, items)
                --
                local winopts = {
                    title = " " .. vim.trim((opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",

                    -- height is number of items, with a max of 80% screen height
                    height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5) + 1,
                    width = 0.7,
                }

                if opts.kind == "codeaction" then
                    winopts = vim.tbl_deep_extend("force", winopts, {
                        -- height is number of items minus 18 lines for the preview, with a max of 80% screen height
                        height = math.floor(math.min(vim.o.lines * 0.8 - 18, #items + 2) + 0.5) + 18,
                        preview = {
                            layout = "vertical",
                            vertical = "down:15,border-top",
                        },
                    })
                end

                if opts.kind ~= "codeaction" then -- or opts.kind ~= "codecompanion.nvim" then
                    -- Auto-width
                    local min_w, max_w = 0.05, 0.80
                    local longest = 0

                    for _, e in ipairs(items) do
                        -- Format the item or convert it to a string
                        local format_entry = opts.format_item and opts.format_item(e) or tostring(e)
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
            end,
        },
    },
    {
        "folke/todo-comments.nvim",
        optional = true,
        -- stylua: ignore
        keys = {
            { "<leader>ft", function () require("todo-comments.fzf").todo() end, desc = "TODOs" },
            { "<leader>fT", function () require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "TODO/Fix/Fixme" },
        },
    },
    {
        "ziontee113/icon-picker.nvim",
        cmd = {
            "IconPickerNormal",
            "IconPickerYank",
            "IconPickerInsert",
        },
        keys = {
            { "<leader>fe", ":IconPickerInsert emoji", desc = "Emoji" },
            { "<leader>fi", ":IconPickerInsert nerd_font_v3", desc = "Nerd Font Icons" },
        },
        opts = {
            disable_legacy_commands = true,
        },
    },
}
