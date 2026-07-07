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
    "echasnovski/mini.icons",
    lazy = true,
    opts = {},
    config = function()
      require("mini.icons").setup()
      -- lets any plugin expecting nvim-web-devicons use mini.icons instead
      MiniIcons.mock_nvim_web_devicons()
    end,
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "echasnovski/mini.icons",
    lazy = false,
    keys = {
      { "<A-,>", "<Cmd>BufferLineMovePrev<CR>", desc = "Move buffer left" },
      { "<A-.>", "<Cmd>BufferLineMoveNext<CR>", desc = "Move buffer right" },
    },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          themable = true,
          numbers = "none",

          -- close/click behavior
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",

          -- no left indicator bar
          indicator = { style = "none" },

          -- kill close icons entirely, keep only the modified dot
          show_buffer_close_icons = false,
          show_close_icon = false,
          modified_icon = "●",

          -- icons via mini.icons (auto-detected once mocked)
          show_buffer_icons = true,
          color_icons = true,

          -- tight tabs, width = text
          separator_style = { "", "" }, -- no visual separators between tiles
          padding = 0,
          tab_size = 0, -- floor width; real width grows only to fit content
          enforce_regular_tabs = false,
          max_name_length = 30,
          truncate_names = true,

          -- tab (vim tabpage) listing on the right
          show_tab_indicators = true,

          always_show_bufferline = true,
          -- diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          persist_buffer_sort = true,
          sort_by = "insert_after_current",
          hover = { enabled = false },
        },
      })
      local groups = {
        "BufferLineBuffer",
        "BufferLineBufferSelected",
        "BufferLineBufferVisible",
        "BufferLineModified",
        "BufferLineModifiedVisible",
        "BufferLineModifiedSelected",
        "BufferLineDiagnostic",
        "BufferLineDiagnosticVisible",
        "BufferLineDiagnosticSelected",
        "BufferLineDuplicate",
        "BufferLineDuplicateVisible",
        "BufferLineDuplicateSelected",
      }

      for _, group in ipairs(groups) do
        vim.api.nvim_set_hl(0, group, { italic = false })
      end

      -- force the modified dot to yellow
      vim.api.nvim_set_hl(0, "BufferLineModified", { fg = "#e5c07b" })
      vim.api.nvim_set_hl(0, "BufferLineModifiedVisible", { fg = "#e5c07b" })
      vim.api.nvim_set_hl(0, "BufferLineModifiedSelected", { fg = "#e5c07b" })
    end,
  },
}
