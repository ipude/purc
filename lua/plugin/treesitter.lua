return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    build = ":TSUpdate",
    cmd = "TSInstall",

    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      require("nvim-treesitter")
        .install({
          "lua",
          "javascript",
          "zig",
          "go",
          "python",
          "html",
          "css",
          "rust",
          "json",
          "markdown",
          "toml",
        })
        :wait(300000)
    end,
  },
}
