---@type LazySpec[]
return {
    {
        "alexpasmantier/krust.nvim",
        lazy = false,
        opts = {
            keymap = "<leader>xs",
            float_win = {
                border = defaults.ui.border.name,
            },
        },
    },
    {
        "Saecki/crates.nvim",
        event = "BufReadPost Cargo.toml",
        opts = {
            lsp = {
                actions = true,
                completion = true,
                enabled = true,
                hover = true,
            },
            popup = {
                autofocus = true,
            },
        },
    },
    {
        "mrcjkb/rustaceanvim",
        config = function()
            ---@module "rustaceanvim"
            vim.g.rustaceanvim = {
                dap = {
                    adapter = false,
                    configuration = false,
                },
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
                        --
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
                        end, "Open external documentation", bufnr, { "n", "v" })

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
                                features = "all",
                                -- Build in sub directory to prevent locking
                                targetDir = true,
                            },
                            check = {
                                command = "clippy",
                                enable = true,
                                features = "all",
                            },
                            completion = {
                                fullFunctionSignatures = { enable = true },
                            },
                            diagnostics = {
                                -- disabled = { "inactive-code", "macro-error", "unresolved-macro-call" },
                                enable = true,
                                experimental = { enable = true },
                                styleLints = { enable = true },
                            },
                            editor = {
                                formatOnType = true,
                            },
                            files = {
                                excludeDirs = {
                                    ".direnv",
                                    ".git",
                                    ".venv",
                                    ".vscode",
                                    "assets",
                                    "bin",
                                    "ci",
                                    "data",
                                    "docs",
                                    "js",
                                    "node_modules",
                                    "target",
                                    "venv",
                                    ".venv",
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
                                enabled = true,
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
                            rustfmt = {
                                extraArgs = { "+nightly" },
                            },
                            semanticHighlighting = {
                                operator = {
                                    specialization = { enable = true },
                                },
                            },
                        },
                    },
                },
            } --[[@as rustaceanvim.Opts]]
        end,
        lazy = false,
        version = "^6", -- Recommended
    },
}
