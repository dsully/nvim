---@type LazySpec[]
return {
    "dmtrKovalenko/fff.nvim",
    build = function()
        require("fff.download").download_or_build_binary()
    end,
    keys = {
        {
            "ff",
            function()
                require("fff").find_files_in_dir(nvim.file.git_root(true) or nvim.file.cwd())
            end,
            desc = "Find Files",
        },
    },
    opts = function()
        return {
            base_path = nvim.file.git_root(true) or nvim.file.cwd(),
            hl = {
                active_file = "Visual",
                border = "FloatBorder",
                cursor = "CursorLine",
                debug = "Comment",
                frecency = "Number",
                matched = "IncSearch",
                normal = "Normal",
                prompt = "Question",
                title = "Title",
            },
            keymaps = {
                close = "<Esc>",
                select = "<CR>",
                select_split = "<C-s>",
                select_vsplit = "<C-v>",
                select_tab = "<C-t>",
                move_up = { "<Up>", "<C-p>" }, -- Multiple bindings supported
                move_down = { "<Down>", "<C-n>" },
                preview_scroll_up = "<C-u>",
                preview_scroll_down = "<C-d>",
            },
            layout = {
                height = 0.85,
                width = 0.85,
                prompt_position = "bottom",
                preview_position = "top",
            },
            preview = {
                binary_file_threshold = 1024,
                filetypes = {
                    log = { tail_lines = 100 },
                    markdown = { wrap_lines = true },
                    svg = { wrap_lines = true },
                    text = { wrap_lines = true },
                },
                imagemagick_info_format_str = "%m: %wx%h, %[colorspace], %q-bit",
                line_numbers = false,
                max_lines = 5000,
                max_size = 10 * 1024 * 1024,
                show_file_info = false,
                wrap_lines = false,
            },
            prompt = " ",
            title = "",
            ui = {
                max_path_width = 120,
            },
            ui_enabled = true,
        }
    end,
}
