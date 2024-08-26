return {
    -- Log file syntax highlighting.
    { "MTDL9/vim-log-highlighting", ft = "log" },

    -- Caddy
    { "isobit/vim-caddyfile", ft = "caddyfile" },

    -- Better vim help.
    {
        "OXY2DEV/helpview.nvim",
        lazy = false,
    },

    -- Apple's PKL language.
    {
        "apple/pkl-neovim",
        event = "BufReadPre *.pkl",
    },

    -- Direnv highlighting & more.
    { "direnv/direnv.vim", ft = "direnv" },

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
                capabilities = require("plugins.lsp.common").setup(),
            })
        end,
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-java/lua-async-await",
            "nvim-java/nvim-java-core",
            "nvim-java/nvim-java-dap",
            "nvim-java/nvim-java-refactor",
            "nvim-java/nvim-java-test",
        },
        ft = { "java" },
        opts = {
            jdk = { auto_install = false },
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        cmd = "RenderMarkdown",
        ft = { "markdown", "vimwiki" },
        keys = {
            {
                "<leader>x",
                function()
                    local char = "x"
                    local current_line = vim.api.nvim_get_current_line()

                    local _, _, checkbox_state = string.find(current_line, "%[([ " .. char .. string.upper(char) .. "])%]")

                    if checkbox_state then
                        local new_state = checkbox_state == " " and char or " "
                        local new_line = string.gsub(current_line, "%[.-%]", "[" .. new_state .. "]")

                        vim.api.nvim_set_current_line(new_line)
                    end
                end,
                desc = "Toggle checkbox",
                { noremap = true, silent = true },
            },
            -- stylua: ignore
            { "<leader>um", function() vim.cmd.RenderMarkdown("toggle") end, desc = "Render Markdown", },
        },
        opts = {
            enabled = false, -- Off by default.
            file_types = { "markdown", "vimwiki" },
            code = {
                sign = false,
                width = "block",
                right_pad = 1,
            },
            heading = {
                sign = false,
                icons = {},
            },
        },
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
                        border = require("config.defaults").ui.border.name,
                    },
                },
                server = {
                    ---@param _client vim.lsp.Client
                    ---@param bufnr integer
                    on_attach = function(_client, bufnr)
                        local keys = require("helpers.keys")

                        keys.bmap("<leader>cc", function()
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
                                },
                            },
                            completion = {
                                fullFunctionSignatures = { enable = true },
                            },
                            diagnostics = {
                                disabled = { "inactive-code", "macro-error", "unresolved-macro-call" },
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
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
            "rcarriga/nvim-dap-ui", -- install debug adapter
        },
        lazy = false,
        version = "^5", -- Recommended
    },
}
