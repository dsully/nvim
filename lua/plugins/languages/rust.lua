---@type LazySpec[]
return {
    {
        "Saecki/crates.nvim",
        event = "BufReadPost Cargo.toml",
        opts = {
            completion = {
                cmp = {
                    enabled = false,
                },
                crates = {
                    enabled = true,
                },
            },
            lsp = {
                actions = true,
                completion = true,
                enabled = true,
                hover = true,
            },
            popup = {
                autofocus = true,
                border = defaults.ui.border.name,
            },
        },
    },
    {
        "mrcjkb/rustaceanvim",
        config = function()
            --
            local clippy_args = {
                "--",
                "--no-deps", -- run Clippy only on the given crate
            }

            if require("helpers.file").is_local_dev() then
                vim.list_extend(clippy_args, {
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
                })
            end

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
                                buildScripts = {
                                    enable = true,
                                },
                            },
                            checkOnSave = not defaults.lsp.rust.bacon,
                            check = {
                                command = "clippy",
                                enable = not defaults.lsp.rust.bacon,
                                extraArgs = clippy_args,
                            },
                            -- checkOnSave = {
                            --     enable = not defaults.lsp.rust.bacon,
                            -- },
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
            }
        end,
        ft = "rust",
        version = "^5", -- Recommended
    },
}
