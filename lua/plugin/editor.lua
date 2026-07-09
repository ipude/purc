-- ===========================
-- Editor Enhancements
-- ===========================
return {
  {
    "kylechui/nvim-surround",
    keys = { "ys", "ds", "cs", { "<C-s>", mode = "v" } },
    config = function()
      require("nvim-surround").setup({})
      vim.keymap.del("v", "S")
      vim.keymap.set("v", "<C-s>", "<Plug>(nvim-surround-visual)", { desc = "Add surround" })
    end,
  },
}
