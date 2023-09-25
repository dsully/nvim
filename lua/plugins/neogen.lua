-- Documentation generation.
return {
    "danymat/neogen",
    keys = {
        {
            -- Under 'c'ode mappings.
            "<leader>cg",
            function()
                require("neogen").generate({})
            end,
            desc = " Generate Docs",
        },
    },
    opts = {
        languages = {
            lua = {
                template = {
                    annotation_convention = "emmylua",
                },
            },
            python = {
                template = {
                    annotation_convention = "reST",
                },
            },
            rust = {
                template = {
                    annotation_convention = "rustdoc",
                },
            },
        },
        snippet_engine = "luasnip",
    },
}
