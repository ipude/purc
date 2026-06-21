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
        on_highlights = function(hl, c)
          hl.Comment = { fg = "#809ab0", italic = false }
          hl.LineNr = { fg = "#6b7a8e" }
          hl.LineNrAbove = { fg = "#6b7a8e" }
          hl.LineNrBelow = { fg = "#6b7a8e" }
          hl.MsgSeparator = { bg = "#809ab0" }
          hl.Statusline = { bg = "#222436" }
        end,
      })
      vim.cmd.colorscheme("tokyonight-moon")
    end,
  },
}
