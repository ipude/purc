return {
  {
    "stevearc/conform.nvim",
    keys = {
      {
        ";f",
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
