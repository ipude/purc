-- ~/.config/nvim/lua/plugins/autopairs.lua
return {
    {
        "altermo/ultimate-autopair.nvim",
        event = { "InsertEnter", "CmdlineEnter" },
        branch = "v0.6",
        opts = {
            disable_in_filetype = { "html", "javascriptreact", "typescriptreact", "jsx", "tsx", "gohtml" },
            use_treesitter = true,
            pairs = {
                { open = "(", close = ")" },
                { open = "[", close = "]" },
                { open = "{", close = "}" },
                { open = '"', close = '"' },
                { open = "'", close = "'" },
                { open = "`", close = "`" },
            },
            override = {
                go = { disable_in_comment = true },
            },
        },
    },

    {
        "windwp/nvim-ts-autotag",
        ft = {
            "html", "xml",
            "javascript", "javascriptreact", "jsx",
            "typescript", "typescriptreact", "tsx",
            "svelte", "vue", "astro",
            "gohtml", "templ",
            "php", "markdown",
        },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-ts-autotag").setup({
                opts = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = false,
                },
                per_filetype = {
                    ["html"]            = { enable_close = true, enable_rename = true, enable_close_on_slash = true },
                    ["xml"]             = { enable_close = true, enable_rename = true, enable_close_on_slash = true },
                    ["javascript"]      = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
                    ["javascriptreact"] = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
                    ["typescript"]      = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
                    ["typescriptreact"] = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
                    ["jsx"]             = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
                    ["tsx"]             = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
                    ["svelte"]          = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
                    ["vue"]             = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
                    ["gohtml"]          = { enable_close = true, enable_rename = true, enable_close_on_slash = true },
                    ["templ"]           = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
                    ["php"]             = { enable_close = true, enable_rename = true, enable_close_on_slash = true },
                    ["markdown"]        = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
                    ["astro"]           = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
                },
            })
        end,
    },
}
