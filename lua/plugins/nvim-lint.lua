return {
    "mfussenegger/nvim-lint",
    config = function()
        local config = vim.env.XDG_CONFIG_HOME

        local lint = require("lint")
        local linters = lint.linters

        linters.typos = {
            cmd = "typos",
            stdin = true,
            append_fname = true,
            args = { "--format", "json", "-" },
            stream = "stdout",
            ignore_exitcode = true,
            env = nil,
            --
            ---@param output string
            ---@param _ number
            ---@return table
            parser = function(output, _)
                local diagnostics = {}

                if output == "" then
                    return {}
                end

                -- From: https://github.com/turboladen/dotfiles/blob/master/.config/nvim/lua/plugins/nvim-lint.lua#L90
                -- typos-cli, when used with `--format json` outputs errors that look like this:
                --
                --   {"type":"binary_file","path":"./lua/init_rs.so"}
                --   {"type":"typo","path":"./lua/plugins/23_package-info-nvim.lua","line_num":15,"byte_offset":37,"typo":"nd","corrections":["and"]}
                --   {"type":"binary_file","path":"./spell/en.utf-8.add.spl"}

                -- Takes an array of suggested corrections (strings) and builds an output string.len
                -- If the array is only one element, the output will be that string; if it's more than one,
                -- the elements are joined with "or" (ex. `{"meow", "taco"}` -> `"meow or taco"`). explicitly
                --
                ---@param all_corrections table
                ---@return string
                local function build_corrections(all_corrections)
                    local corrections = ""

                    if #all_corrections == 1 then
                        return all_corrections[1]
                    end

                    for _, correction in ipairs(all_corrections) do
                        corrections = corrections .. " or " .. correction
                    end

                    return corrections
                end

                -- Split the output string on newlines, where each line contains an entry of JSON.
                for json in string.gmatch(output, "[%S]+") do
                    local item = vim.json.decode(json)

                    if item ~= nil then
                        local line_num = item.line_num - 1
                        local corrections = build_corrections(item.corrections)

                        table.insert(diagnostics, {
                            lnum = line_num,
                            end_lnum = line_num,
                            col = item.byte_offset,
                            end_col = item.byte_offset + item.type:len(),
                            severity = vim.diagnostic.severity.WARN,
                            source = "[typos] " .. item.type,
                            message = "`" .. item.typo .. "` should be `" .. corrections .. "`",
                        })
                    end
                end

                return diagnostics
            end,
        }

        linters.gitlint = {
            cmd = "gitlint",
            stdin = true,
            args = {
                string.format("--config=%s/gitlint.ini", config),
                "--msg-filename",
                "-",
            },
            stream = "stderr",
            ignore_exitcode = true,
            env = nil,
            parser = require("lint.parser").from_pattern([[(%d+): (%w+) (.+)]], { "lnum", "code", "message" }),
        }

        linters.markdownlint.args = {
            function()
                return string.format("--config=%s/markdownlint/config.yaml", config)
            end,
        }

        linters.yamllint.args = {
            function()
                return string.format("--config=%s/yamllint.yaml", config)
            end,
        }

        lint.linters_by_ft = {
            bash = { "shellcheck", "typos" },
            c = { "typos" },
            cpp = { "typos" },
            fish = { "fish", "typos" },
            ghaction = { "actionlint", "typos" },
            gitcommit = { "gitlint", "typos" },
            htmldjango = { "curlylint" },
            java = { "typos" },
            jinja = { "curlylint", "typos" },
            json = { "typos" },
            lua = { "typos" },
            markdown = { "markdownlint", "typos" },
            python = { "typos" }, -- "mypy", "ruff"
            rst = { "rstcheck", "typos" },
            rust = { "typos" },
            sh = { "shellcheck", "typos" },
            text = { "typos" },
            yaml = { "typos", "yamllint" },
        }

        vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "BufWritePost", "TextChanged", "InsertLeave" }, {
            callback = function(args)
                -- Ignore 3rd party code.
                if args.file:match("/(node_modules|__pypackages__|site_packages)/") then
                    return
                end

                if not vim.g.large_file then
                    require("lint").try_lint()
                end
            end,
            group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        })
    end,
    event = { "BufReadPre", "BufNewFile" },
}
