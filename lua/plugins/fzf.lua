---@type LazySpec[]
return {
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
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

            return {

                { "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
                { "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },
                {
                    "<leader>f/",
                    function()
                        require("helpers.picker").grep_curbuf_cword()
                    end,
                    desc = "Current Buffer <cword>",
                },
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
                { "<leader>fw", pick("grep_cword"), desc = "Words" },
                {
                    "<leader>fn",
                    function()
                        require("helpers.picker").notifications()
                    end,
                    desc = "Notifications",
                },
                {
                    "<leader>fP",
                    function()
                        require("helpers.picker").parents()
                    end,
                    desc = "Parent dirs",
                },
                {
                    "<leader>fR",
                    function()
                        require("helpers.picker").repositories()
                    end,
                    desc = "Repositories",
                },
                {
                    "<leader>fS",
                    function()
                        require("helpers.picker").subdirectory()
                    end,
                    desc = "Subdirectories",
                },

                { "gD", pick("lsp_typedefs"), desc = "Goto Type Definition" },
                { "gd", pick("lsp_definitions", nil, { unique_line_items = true }), desc = "Goto Definition" },
                { "gi", pick("lsp_implementations"), desc = "Goto Implementation" },
                { "gi", pick("lsp_implementations"), desc = "Goto Implementation" },
                { "grr", pick("lsp_references"), desc = "References", nowait = true },
                { "gO", pick("lsp_document_symbols"), desc = "Symbols: Document" },
                { "z=", pick("spell_suggest"), desc = "Suggest Spelling" },
            }
        end,
        config = function(_, opts)
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
                rg_glob = true,
                --- @param query string First returned string is the new search query
                --- @param _opts string Second returned string are (optional) additional rg flags
                --- @return string, string?
                rg_glob_fn = function(query, _opts)
                    local regex, flags = query:match("^(.-)%s%-%-(.*)$")

                    -- If no separator is detected will return the original query
                    return (regex or query), flags
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
}
