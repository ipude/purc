return {
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
                require("tokyonight").setup({
                    style = "moon",
                    styles = {
                        comments = { italic = false },
                        keywords = { italic = false },
                        functions = { italic = false },
                        variables = { italic = false },
                        sidebars = "dark",
                        floats = "dark",
                    },

                    transparent = false,
                    terminal_colors = true,
                    dim_inactive = false,
                })

                vim.cmd.colorscheme("tokyonight-moon")
        end,
    },
}
