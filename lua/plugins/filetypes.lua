return {
    -- Log file syntax highlighting.
    { "MTDL9/vim-log-highlighting", ft = "log" },

    -- Justfile, as the treesitter parser is rough.
    { "NoahTheDuke/vim-just", ft = "just" },

    -- Caddy
    { "isobit/vim-caddyfile", ft = "caddyfile" },

    -- Markdown helper.
    { "oncomouse/markdown.nvim", ft = "markdown", opts = {} },

    { "direnv/direnv.vim", ft = "direnv" },

    -- JSON Sorting
    { "2nthony/sortjson.nvim", ft = "json", opts = true },

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
        "mfussenegger/nvim-jdtls",
        config = function()
            local common = require("plugins.lsp.common")

            local base = require("mason-registry").get_package("jdtls"):get_install_path()
            local configuration = ""

            if vim.g.os == "Darwin" then
                configuration = base .. "/config_mac"
            else
                configuration = base .. "/config_linux"
            end

            local workspace = vim.env.XDG_CACHE_HOME .. "/jdtls/" .. vim.fn.fnamemodify(vim.uv.cwd(), ":p:h:t")

            vim.uv.fs_mkdir(workspace, 511)

            require("jdtls").start_or_attach({
                capabilities = common.capabilities(),
                cmd = {
                    "java",
                    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                    "-Dosgi.bundles.defaultStartLevel=4",
                    "-Declipse.product=org.eclipse.jdt.ls.core.product",
                    "-Dlog.protocol=true",
                    "-Dlog.level=ALL",
                    "-Dfile.encoding=utf-8",
                    "-Xms1g",
                    "--add-modules=ALL-SYSTEM",
                    "--add-opens",
                    "java.base/java.util=ALL-UNNAMED",
                    "--add-opens",
                    "java.base/java.lang=ALL-UNNAMED",
                    "-javaagent:" .. base .. "/lombok.jar",
                    "-jar",
                    vim.fn.glob(base .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
                    "-configuration",
                    configuration,
                    "-data",
                    workspace,
                },
                on_attach = common.on_attach,
                settings = {
                    codeGeneration = {
                        toString = {
                            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                        },
                        useBlocks = true,
                    },
                    java = {
                        configuration = {
                            eclipse = {
                                downloadSources = true,
                            },
                            implementationsCodeLens = {
                                enabled = true,
                            },
                            inlayHints = {
                                parameterNames = {
                                    enabled = "all", -- literals, all, none
                                },
                            },
                            maven = {
                                downloadSources = true,
                            },
                            referencesCodeLens = {
                                enabled = true,
                            },
                            references = {
                                includeDecompiledSources = true,
                            },
                            runtimes = {
                                path = vim.env.JAVA_HOME,
                            },
                        },
                        extendedClientCapabilities = vim.tbl_deep_extend("force", require("jdtls").extendedClientCapabilities, {
                            resolveAdditionalTextEditsSupport = true,
                            onCompletionItemSelectedCommand = "editor.action.triggerParameterHints",
                            workspace = { configuration = true },
                        }),
                        signatureHelp = {
                            enabled = true,
                        },
                    },
                    sources = {
                        organizeImports = {
                            starThreshold = 9999,
                            staticStarThreshold = 9999,
                        },
                    },
                },
                flags = {
                    allow_incremental_sync = true,
                    server_side_fuzzy_completion = true,
                },
            })
        end,
        ft = "java",
    },
}
