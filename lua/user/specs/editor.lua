-- ===========================
-- Editor Enhancements
-- ===========================
return {
    {
        "kylechui/nvim-surround",
        keys = { "ys", "ds", "cs", { "S", mode = "v" } },
        config = function()
            require("nvim-surround").setup({})
        end,
    },
    {
        dir = vim.fn.stdpath("config"),
        name = "term",
        keys = { "<F1>", "<F12>" },
        config = function()
            require("user.config.ide.ide.toggleterm")
        end,
    },
}
