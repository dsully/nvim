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
    opts = function()
        local conf = require("fff.conf")
        local file_picker = require("fff.file_picker")

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

                            if name ~= "" and vim.fn.filereadable(name) == 1 then
                                current_file_cache = name
                            end
                        end
                    end

                    local config = conf.get()
                    local query = ctx.filter.search or ""
                    local max_results = config.max_results or 100
                    local max_threads = config.max_threads or 4
                    local results = file_picker.search_files(query, current_file_cache, max_results, max_threads, nil)

                    ---@type snacks.picker.finder.Item[]
                    local items = {}

                    for _, fff_item in ipairs(results) do
                        items[#items + 1] = {
                            text = fff_item.relative_path or fff_item.name,
                            file = fff_item.path,
                        } --[[@as snacks.picker.finder.Item]]
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

        require("fff.file_picker").setup()

        return {
            base_path = nvim.file.git_root(true) or nvim.file.cwd(),
        }
    end,
}
