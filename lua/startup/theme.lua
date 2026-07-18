vim.pack.add({ "https://github.com/folke/tokyonight.nvim" })
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
  on_highlights = function(hl)
    hl.NormalFloat = { bg = "#2f334d" }
    hl.FloatBorder = { fg = "#65bcff", bg = "#2f334d", bold = true }
    hl.FloatShadowThrough = { bg = "#222436" }
    hl.FloatShadow = { bg = "#222436" }
    hl.FloatTitle = { bg = "#65bcff", fg = "#000000" }
    hl.FloatFooter = { bg = "#65bcff", fg = "#000000" }
    hl.Comment = { fg = "#809ab0", italic = false }
    hl.LineNr = { fg = "#6b7a8e" }
    hl.LineNrAbove = { fg = "#6b7a8e" }
    hl.LineNrBelow = { fg = "#6b7a8e" }
    hl.MsgSeparator = { bg = "#809ab0" }
    hl.Statusline = { bg = "#222436" }
    hl.Search = { fg = "#1e2030", bg = "#ffc777", bold = true }
    hl.Search = { fg = "#1e2030", bg = "#e0a552", bold = true }
    hl.IncSearch = { fg = "#1e2030", bg = "#e0555f", bold = true }
    hl.CurSearch = { fg = "#1e2030", bg = "#e0754a", bold = true }
    hl.Cursor = { fg = "#1e2030", bg = "#ffffff", bold = true }
    hl.lCursor = { fg = "#1e2030", bg = "#ffffff", bold = true }
  end,
})
vim.cmd.colorscheme("tokyonight-moon")
