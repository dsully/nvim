local pickers = require("helpers.picker")
local pick = pickers.pick

return {
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        keys = {
            { "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
            { "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },

            { "<leader>f/", pick("lgrep_curbuf"), desc = "Current Buffer" },
            { "<leader>f;", pick("resume"), desc = "Resume Picker" },
            { "<leader>fC", pick("git_bcommits"), desc = "Buffer Commits" },
            { "<leader>fD", pick("diagnostics_document"), desc = "Diagnostics: Document" },
            { "<leader>fG", pick("git_files"), desc = "Git Files" },
            { "<leader>fS", pick("lsp_dynamic_workspace_symbols"), desc = "Symbols: Workspace" },
            { "<leader>fc", pick("git_commits"), desc = "Git Commits" },
            { "<leader>fd", pick("diagnostics_workspace"), desc = "Diagnostics: Workspace" },
            { "<leader>ff", pick("files"), desc = "Files" },
            { "<leader>fg", pick("live_grep"), desc = "Live Grep" },
            { "<leader>fk", pick("keymaps"), desc = "Key Maps" },
            { "<leader>fo", pick("oldfiles"), desc = "Recently Opened" },
            { "<leader>fq", pick("quickfix"), desc = "Quickfix List" },
            { "<leader>fs", pick("lsp_document_symbols"), desc = "Symbols: Document" },
            { "<leader>fw", pick("grep_cword"), desc = "Words" },

            { "<leader>fn", pickers.notifications, desc = "Notifications" },

            { "<leader>fP", pickers.parents, desc = "Parent dirs" },
            { "<leader>cds", pickers.subdirectory, desc = "Subdirectories" },
            { "<leader>fR", pickers.repositories, desc = "Repositories" },

            { "<leader>f.", pickers.file(vim.env.XDG_CONFIG_HOME), desc = "dotfiles" },
            { "<leader>fp", pickers.file(require("lazy.core.config").options.root), desc = "Plugins" },

            { "gi", pick("lsp_implementations"), desc = "Goto Implementation" },
            { "gi", pick("lsp_implementations"), desc = "Goto Implementation" },
            { "gd", pick("lsp_definitions"), desc = "Goto Definition" },
            { "grr", pick("lsp_references"), desc = "References", nowait = true },
            { "gy", pick("lsp_typedefs"), desc = "Goto T[y]pe Definition" },
            { "z=", pick("spell_suggest"), desc = "Suggest Spelling" },
        },
        init = function()
            --
            -- Override the default select function to use fzf-lua.
            --
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.select = function(...)
                require("lazy").load({ plugins = { "fzf-lua" } })

                -- https://github.com/ibhagwan/fzf-lua/issues/717
                require("fzf-lua").register_ui_select(function(fzf_opts, items)
                    --
                    return vim.tbl_deep_extend("force", fzf_opts, {
                        prompt = " ",
                        winopts = {
                            title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
                            title_pos = "center",
                        },
                    }, fzf_opts.kind == "codeaction" and {
                        winopts = {
                            height = math.floor(math.min(vim.o.lines * 0.8 - 30, #items) + 0.5) + 30,
                            layout = "vertical",
                        },
                    } or {
                        winopts = {
                            height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
                            row = 0.40,
                        },
                    })
                end)

                return vim.ui.select(...)
            end
        end,
        opts = function()
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

            local defaults = require("config.defaults")

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
            config.defaults.actions.files["ctrl-r"] = function(_, ctx)
                local o = vim.deepcopy(ctx.__call_opts)
                o.root = o.root == false
                o.cwd = nil
                o.buf = ctx.__CTX.bufnr

                if not o.cwd and o.root ~= false then
                    o.cwd = require("helpers.lsp").find_root(o.buf)
                end

                fzf.files(o)
            end

            config.defaults.actions.files["alt-c"] = config.defaults.actions.files["ctrl-r"]
            config.set_action_helpstr(config.defaults.actions.files["ctrl-r"], "toggle-root-dir")

            local opts = add_prompt(require("fzf-lua.profiles.default-title"))

            return vim.tbl_deep_extend("force", opts, {
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
                    ["--exact"] = "",
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
                },
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
            })
        end,
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
        event = "LazyFile",
        init = function()
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
        cmd = { "TodoTrouble", "TodoTelescope" },
        event = "LazyFile",
        -- stylua: ignore
        keys = {
            { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
            { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
            { "<leader>ft", function () require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME", "XXX" } }) end, desc = "TODOs" },
        },
        opts = {
            highlight = {
                pattern = [[(KEYWORDS)\s*(\([^\)]*\))?:]],
            },
        },
    },
    {
        "folke/trouble.nvim",
        cmd = { "Trouble" },
        dependencies = "echasnovski/mini.icons",
        keys = {
            {
                "<leader>xx",
                function()
                    require("trouble").toggle({ focus = true, mode = "diagnostics" })
                end,
                desc = "Trouble",
            },
        },
        opts = {
            auto_preview = false,
            use_diagnostic_signs = true,
        },
    },
    {
        "MagicDuck/grug-far.nvim",
        cmd = "GrugFar",
        keys = {
            {
                "<leader>sr",
                function()
                    local grug = require("grug-far")
                    local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
                    grug.grug_far({
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
}
