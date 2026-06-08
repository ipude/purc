-- ===========================
-- Mini.nvim Suite
-- ===========================
return {
    {
        "echasnovski/mini.clue",
        event = "VeryLazy",
        config = function()
            require("user.mini.miniclues")
        end,
    },
    {
        "nvim-mini/mini.notify",
        event = "VeryLazy",
        config = function()
            require("user.mini.mini_notify")
        end,
    },
    {
        "nvim-mini/mini.indentscope",
        version = false,
        event = "VeryLazy",
        config = function()
            require("user.mini.mini_indentscope")
        end,
    },
    {
        "echasnovski/mini.move",
        keys = {
            { "<A-Left>", mode = { "n", "v" } },
            { "<A-Right>", mode = { "n", "v" } },
            { "<A-Down>", mode = { "n", "v" } },
            { "<A-Up>", mode = { "n", "v" } },
        },
        config = function()
            require("mini.move").setup({
                mappings = {
                    left = "<A-Left>",
                    right = "<A-Right>",
                    down = "<A-Down>",
                    up = "<A-Up>",
                    line_left = "<A-Left>",
                    line_right = "<A-Right>",
                    line_down = "<A-Down>",
                    line_up = "<A-Up>",
                },
                options = {
                    reindent_linewise = true,
                },
            })
        end,
    },
    {
        "echasnovski/mini.icons",
        version = false,
        event = "VeryLazy",
        config = function()
            require("mini.icons").setup()
        end,
    },
}
