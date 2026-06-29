-- ===========================
-- Utility Features
-- ===========================
return {
  {
    "mg979/vim-visual-multi",
    keys = {
      { "<C-n>", mode = { "n", "v" } },
      { "<C-Down>" },
      { "<C-Up>" },
    },
  },
  {
    "mbbill/undotree",
    keys = {
      { "<leader>ut", vim.cmd.UndotreeToggle, desc = "Toggle Undotree" },
    },
    config = function()
      vim.g.undotree_WindowLayout = 2 -- tree on left, diff below
      vim.g.undotree_SplitWidth = 20
      vim.g.undotree_DiffpanelHeight = 12
      vim.g.undotree_SetFocusWhenToggle = 1 -- auto-focus the tree on open
      vim.g.undotree_ShortIndicators = 1 -- compact time indicators
      vim.g.undotree_HelpLine = 0 -- hide "press ? for help" line
      vim.g.undotree_DiffAutoOpen = 1 -- show diff panel automatically
      vim.g.undotree_RelativeTimestamp = 1 -- "2 min ago" instead of epoch
    end,
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup({
        lsp = {
          enabled = true,
          actions = true,
          completion = true,
          hover = true,
        },
      })
    end,
  },
}
