return {
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>tt",
        function()
          require("conform").format()
        end,
        mode = "n",
        desc = "Format buffer",
      },
    },
    config = function()
      require("tools.formatter")
    end,
  },
}
