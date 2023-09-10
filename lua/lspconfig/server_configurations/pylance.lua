return {
    default_config = {
        cmd = { "pylance", "--stdio" },
        commands = {
            LspPyrightRestartServer = {
                function()
                    vim.lsp.buf.execute_command({
                        command = "pyright.restartserver",
                        arguments = { vim.uri_from_bufnr(0) },
                    })
                end,
                description = "Restart Server",
            },
            PylanceExtractMethod = {
                function()
                    vim.lsp.buf.execute_command({
                        command = "pylance.extractMethod",
                        arguments = { vim.uri_from_bufnr(0):gsub("file://", ""), vim.lsp.util.make_given_range_params(nil, nil, 0, nil).range },
                    })
                end,
                description = "Extract Method",
            },
            PylanceExtractVariable = {
                function()
                    vim.lsp.buf.execute_command({
                        command = "pylance.extractVariable",
                        arguments = { vim.uri_from_bufnr(0):gsub("file://", ""), vim.lsp.util.make_given_range_params(nil, nil, 0, nil).range },
                    })
                end,
                description = "Extract Variable",
            },
            PylanceOrganizeImports = {
                function()
                    vim.lsp.buf.execute_command({
                        command = "pyright.organizeimports",
                        arguments = { vim.uri_from_bufnr(0) },
                    })
                end,
                description = "Organize Imports",
            },
        },
        filetypes = { "python" },
        handlers = {
            ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
                result.diagnostics = vim.tbl_filter(function(diagnostic)
                    -- Allow kwargs to be unused
                    if diagnostic.message == '"kwargs" is not accessed' then
                        return false
                    end

                    -- Prefix variables with an underscore to ignore
                    if string.match(diagnostic.message, '"_.+" is not accessed') then
                        return false
                    end

                    -- Prevent pyright from reporting & unused "undefined" variables; flake8/ruff can handle that.
                    if diagnostic.code == "reportUndefinedVariable" then
                        return false
                    end

                    return true
                end, result.diagnostics)

                vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
            end,
            ["workspace/executeCommand"] = function(_, result, ctx)
                --
                if ctx.params.command:match("WithRename") then
                    ctx.params.command = ctx.params.command:gsub("WithRename", "")
                    vim.lsp.buf.execute_command(ctx.params)
                end

                if result then
                    if result.label == "Extract Method" then
                        local old_value = result.data.newSymbolName
                        local file = vim.tbl_keys(result.edits.changes)[1]
                        local range = result.edits.changes[file][1].range.start
                        local params = { textDocument = { uri = file }, position = range }
                        local client = vim.lsp.get_client_by_id(ctx.client_id)

                        local prompt_opts = {
                            prompt = "New Method Name: ",
                            default = old_value,
                        }

                        if not old_value:find("new_var") then
                            range.character = range.character + 5
                        end

                        vim.ui.input(prompt_opts, function(input)
                            if not input or #input == 0 then
                                return
                            end

                            params.newName = input

                            if client then
                                local handler = client.handlers["textDocument/rename"] or vim.lsp.handlers["textDocument/rename"]
                                client.request("textDocument/rename", params, handler, ctx.bufnr)
                            end
                        end)
                    end
                end
            end,
        },
        root_dir = function(fname)
            local lsputil = require("lspconfig.util")
            local markers = {
                "Pipfile",
                "pyproject.toml",
                "pyrightconfig.json",
                "setup.py",
                "setup.cfg",
                "requirements.txt",
            }
            return lsputil.root_pattern(unpack(markers))(fname) or lsputil.find_git_ancestor(fname) or lsputil.path.dirname(fname)
        end,
        settings = {
            python = {
                analysis = vim.empty_dict(),
            },
            telemetry = {
                telemetryLevel = "off",
            },
        },
        single_file_support = true,
    },
}
