return {
    -- Log file syntax highlighting.
    { "MTDL9/vim-log-highlighting", ft = "log" },

    -- Caddy
    { "isobit/vim-caddyfile", ft = "caddyfile" },
    { "https://github.com/Samonitari/tree-sitter-caddy", ft = "caddyfile" },

    -- Better vim help.
    {
        "OXY2DEV/helpview.nvim",
        lazy = false,
    },

    -- Apple's PKL language.
    {
        "apple/pkl-neovim",
        build = function()
            require("pkl-neovim.internal").init()

            -- Set up syntax highlighting.
            vim.cmd.TSInstall({ "pkl", bang = true })
        end,
        event = "BufReadPre *.pkl",
    },

    {
        "vuki656/package-info.nvim",
        config = function()
            local package = require("package-info")

            package.setup()

            vim.keymap.set("n", "<leader>nu", package.update, { desc = "Package: Update package on line" })
            vim.keymap.set("n", "<leader>nd", package.delete, { desc = "Package: Delete package on line" })
            vim.keymap.set("n", "<leader>ni", package.install, { desc = "Package: Install new package" })
            vim.keymap.set("n", "<leader>nv", package.change_version, { desc = "Package: Change version of package on line" })
        end,
        event = "BufRead package.json",
    },

    {
        "nvim-java/nvim-java",
        config = function(_, opts)
            require("java").setup(opts)
            require("lspconfig").jdtls.setup({
                capabilities = require("helpers.lsp").capabilities(),
            })
        end,
        ft = { "java" },
        opts = {
            jdk = { auto_install = false },
        },
    },
    { "nvim-java/lua-async-await" },
    { "nvim-java/nvim-java-core" },
    { "nvim-java/nvim-java-dap" },
    { "nvim-java/nvim-java-refactor" },
    { "nvim-java/nvim-java-test" },

    { "jghauser/follow-md-links.nvim", ft = "markdown" },
    {
        "OXY2DEV/markview.nvim",
        ft = { "markdown", "vimwiki" },
        keys = {
            {
                "<space>tc",
                function()
                    local char = defaults.icons.misc.check
                    local current_line = vim.api.nvim_get_current_line()

                    local _, _, current_state = string.find(current_line, "%[([ " .. char .. string.upper(char) .. "])%]")

                    if current_state then
                        local new_state = current_state == " " and char or " "
                        local new_line = string.gsub(current_line, "%[.-%]", "[" .. new_state .. "]")

                        vim.api.nvim_set_current_line(new_line)
                    end
                end,
                desc = "Checkbox",
                { noremap = true, silent = true },
            },
        },
        opts = function()
            require("snacks")
                .toggle({
                    name = "Markdown",
                    get = function()
                        return require("markview").state.enable
                    end,
                    set = function()
                        vim.cmd.Markview("toggleAll")
                    end,
                })
                :map("<space>tm")

            local presets = require("markview.presets")

            return {
                buf_ignore = defaults.ignored.buffer_types,
                checkboxes = presets.checkboxes.nerd,
                code_blocks = {
                    icons = "mini",
                },
                headings = presets.headings.glow,
                horizontal_rules = presets.horizontal_rules.thick,
                hybrid_modes = { "n" },
                tables = {
                    --stylua: ignore
                    text = {
                        top       = { "┌", "─", "┐", "┬" },
                        header    = { "│", "│", "│" },
                        separator = { "├", "┼", "┤", "─" },
                        row       = { "│", "│", "│" },
                        bottom    = { "└", "─", "┘", "┴" },
                    },
                },
            }
        end,
    },
    {
        "mrcjkb/rustaceanvim",
        config = function()
            vim.g.rustaceanvim = {
                -- Plugin configuration
                tools = {
                    code_actions = {
                        ui_select_fallback = true,
                    },
                    float_win_config = {
                        border = defaults.ui.border.name,
                    },
                },
                server = {
                    ---@param _client vim.lsp.Client
                    ---@param bufnr integer
                    on_attach = function(_client, bufnr)
                        local keys = require("helpers.keys")

                        keys.bmap("<leader>cC", function()
                            vim.cmd.RustLsp("flyCheck")
                        end, "Check", bufnr)

                        keys.bmap("<leader>ce", function()
                            vim.cmd.RustLsp("openCargo")
                        end, "Open Cargo.toml", bufnr)

                        keys.bmap("gP", function()
                            vim.cmd.RustLsp("parentModule")
                        end, "Open parent module", bufnr)

                        keys.bmap("gx", function()
                            vim.cmd.RustLsp("openDocs")
                        end, "Open external documentation", bufnr, { "n", "x" })

                        -- keys.bmap("gra", function()
                        --     vim.cmd.RustLsp("codeAction")
                        -- end, "󱘗 Code Action", bufnr)

                        keys.bmap("K", function()
                            vim.cmd.RustLsp({ "hover", "actions" })
                        end, "󱘗 Documentation", bufnr)

                        vim.cmd.compiler("cargo")
                    end,
                    default_settings = {
                        -- https://github.com/rust-lang/rust-analyzer/blob/master/docs/user/generated_config.adoc
                        -- https://rust-analyzer.github.io/manual.html#configuration
                        ["rust-analyzer"] = {
                            cargo = {
                                buildScripts = {
                                    enable = true,
                                },
                            },
                            check = {
                                command = "clippy",
                                enable = not defaults.lsp.rust.bacon,
                                extraArgs = {
                                    "--",
                                    "--no-deps", -- run Clippy only on the given crate
                                    -- Deny, Warn, Allow, Forbid
                                    "-Wclippy::correctness", -- code that is outright wrong or useless
                                    "-Wclippy::complexity", -- code that does something simple but in a complex way
                                    "-Wclippy::suspicious", -- code that is most likely wrong or useless
                                    "-Wclippy::style", -- code that should be written in a more idiomatic way
                                    "-Wclippy::perf", -- code that can be written to run faster
                                    "-Wclippy::pedantic", -- lints which are rather strict or have occasional false positives
                                    -- Allow overly pedantic lints
                                    "-Aclippy::doc_markdown",
                                    "-Aclippy::missing_errors_doc",
                                    "-Aclippy::missing_panics_doc",
                                },
                            },
                            completion = {
                                fullFunctionSignatures = { enable = true },
                            },
                            diagnostics = {
                                disabled = { "inactive-code", "macro-error", "unresolved-macro-call" },
                                enable = not defaults.lsp.rust.bacon,
                                experimental = { enable = true },
                                styleLints = { enable = true },
                            },
                            files = {
                                excludeDirs = {
                                    ".direnv",
                                    ".git",
                                    ".venv",
                                    ".vscode",
                                    "assets",
                                    "ci",
                                    "data",
                                    "docs",
                                    "js",
                                    "target",
                                    "venv",
                                },
                                -- watcher = "server",
                            },
                            imports = {
                                granularity = {
                                    group = "module",
                                },
                                prefix = "self",
                            },
                            inlayHints = {
                                closureReturnTypeHints = { enable = "with_block" },
                                closureStyle = "rust_analyzer",
                                parameterHints = { enable = false },
                            },
                            lens = {
                                references = {
                                    adt = { enable = true },
                                    method = { enable = true },
                                },
                            },
                            procMacro = {
                                -- Don't expand some problematic proc_macros
                                ignored = {
                                    ["async-trait"] = { "async_trait" },
                                    ["napi-derive"] = { "napi" },
                                    ["async-recursion"] = { "async_recursion" },
                                    ["async-std"] = { "async_std" },
                                },
                            },
                            rust = {
                                analyzerTargetDir = true,
                            },
                            -- rustfmt = {
                            --     extraArgs = { "+nightly" },
                            -- },
                            semanticHighlighting = {
                                operator = {
                                    specialization = { enable = true },
                                },
                            },
                        },
                    },
                },
            }
        end,
        lazy = false,
        version = "^5", -- Recommended
    },
    {
        "ghostty",
        cond = function()
            return vim.fn.executable("ghostty") == 1
        end,
        dir = "/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/",
        lazy = false,
    },
}
