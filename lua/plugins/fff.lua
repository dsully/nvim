---@type string?
local current_file_cache = nil

---@type LazySpec
return {
    "dmtrKovalenko/fff.nvim",
    build = function()
        require("fff.download").download_or_build_binary()
    end,
    keys = {
        --stylua: ignore start
        { "ff", function() Snacks.picker.fff() end, desc = "Find Files" },
        { "<leader>ff", function() Snacks.picker.fff() end, desc = "Find Files" },
        --stylua: ignore end
    },
    config = function()
        if vim.uv.fs_stat(vim.fn.stdpath("data") .. "/lazy/fff.nvim/target") == nil then
            require("fff.download").download_or_build_binary()
        end

        require("fff").setup({})
        local conf = require("fff.conf")

        if Snacks and pcall(require, "snacks.picker") then
            --- FFF -> Snacks picker integration.
            --- Uses fff's Rust-powered fuzzy search as a Snacks picker source,
            --- preserving fff's frecency-based ordering while using Snacks' UI/icons.
            ---
            ---@type snacks.picker.Config
            Snacks.picker.sources.fff = {
                title = "Files",
                ---@param _opts snacks.picker.Config
                ---@param ctx snacks.picker.finder.ctx
                ---@return snacks.picker.finder.Item[]
                finder = function(_opts, ctx)
                    if not current_file_cache then
                        local buf = vim.api.nvim_get_current_buf()

                        if buf and vim.api.nvim_buf_is_valid(buf) then
                            local name = vim.api.nvim_buf_get_name(buf)

                            if name ~= "" and vim.uv.fs_access(name, "R") == 1 then
                                current_file_cache = name
                            end
                        end
                    end

                    local config = conf.get()
                    local query = ctx.filter.search or ""
                    local max_results = config.max_results or 100
                    local max_threads = config.max_threads or 4

                    local results = {}
                    local ok, file_picker = pcall(require, "fff.file_picker")

                    if ok and file_picker and type(file_picker.search_files) == "function" then
                        local search_files = file_picker.search_files
                        results = search_files(query, current_file_cache, max_results, max_threads, nil)
                    end

                    ---@type snacks.picker.finder.Item[]
                    local items = {}

                    for _, entry in ipairs(results) do
                        ---@type string?
                        local file = entry.relative_path or entry.name

                        if file and file ~= "" then
                            local item = {
                                text = file,
                                file = file,
                            } --[[@as snacks.picker.finder.Item]]

                            if config.base_path and config.base_path ~= "" and vim.fs.normalize(file) ~= file then
                                ---@diagnostic disable-next-line: inject-field
                                item.cwd = config.base_path
                            end

                            items[#items + 1] = item
                        end
                    end

                    return items
                end,

                format = "file",
                sort = { fields = { "idx" } },
                matcher = {
                    sort_empty = false,
                    sort = false,
                },
                on_close = function()
                    current_file_cache = nil
                end,
                live = true,
            }
        end

        if pcall(require, "fff.file_picker") then
            require("fff.file_picker").setup()
        end
    end,
    lazy = false,
}
