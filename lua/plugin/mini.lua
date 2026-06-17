-- ===========================
-- Mini.nvim
-- ===========================
return {
  {
    "echasnovski/mini.clue",
    event = "VeryLazy",
    config = function()
      require("mini.miniclues")
    end,
  },
  {
    "nvim-mini/mini.notify",
    event = "VeryLazy",
    config = function()
      require("mini.mini_notify")
    end,
  },
  {
    "nvim-mini/mini.indentscope",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.mini_indentscope")
    end,
  },
  {
    "echasnovski/mini.icons",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.icons").setup()
    end,
  },
  {
    "echasnovski/mini.tabline",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.mini_bufferline")
    end,
  },

  {
    "echasnovski/mini.move",
    keys = {
      { "<A-h>", mode = { "n", "v" } },
      { "<A-l>", mode = { "n", "v" } },
      { "<A-j>", mode = { "n", "v" } },
      { "<A-k>", mode = { "n", "v" } },
    },
    config = function()
      require("mini.move").setup({
        mappings = {
          left = "<A-h>",
          right = "<A-l>",
          down = "<A-j>",
          up = "<A-k>",
          line_left = "<A-h>",
          line_right = "<A-l>",
          line_down = "<A-j>",
          line_up = "<A-k>",
        },
        options = {
          reindent_linewise = true,
        },
      })
    end,
  },

  {
    "echasnovski/mini.sessions",
    version = "*",
    keys = {
      { "<leader>sc", desc = "session create" },
      { "<leader>ss", desc = "session save" },
      { "<leader>sf", desc = "session fuzzy" },
      { "<leader>sd", desc = "session delete" },
      { "<leader>si", desc = "session info" },
    },
    opts = {
      autoread = false,
      autowrite = false,
      directory = vim.fn.stdpath("data") .. "/sessions",
      file = "", -- disable local session file
      verbose = { read = false, write = true, delete = true },
    },
    config = function(_, opts)
      vim.opt.sessionoptions = {
        "buffers",
        "curdir",
        "tabpages",
        "winsize",
        "winpos",
      }

      local ms = require("mini.sessions")
      ms.setup(opts)

      -- Kill terminals before save (same as ResessionSavePre)
      local function clean_terms()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            if name:match("^term://") then
              pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
          end
        end
      end

      local function get_sessions()
        return vim.tbl_keys(ms.detected)
      end

      local function current_session()
        return vim.g.miniSessions_current_session
      end

      -- CREATE: <leader>sc
      vim.keymap.set("n", "<leader>sc", function()
        local default = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        vim.ui.input({ prompt = "Session: ", default = default }, function(name)
          if name and name ~= "" then
            clean_terms()
            ms.write(name)
          end
        end)
      end, { desc = "session create" })

      -- SAVE: <leader>ss
      vim.keymap.set("n", "<leader>ss", function()
        local cur = current_session()
        if cur and cur ~= "" then
          clean_terms()
          ms.write(cur)
        else
          print("No session. Use <leader>sc")
        end
      end, { desc = "session save" })

      -- LOAD: <leader>sf
      vim.keymap.set("n", "<leader>sf", function()
        local sessions = get_sessions()
        if #sessions == 0 then
          print("No sessions")
          return
        end
        require("fzf-lua").fzf_exec(sessions, {
          prompt = "Load> ",
          actions = {
            ["default"] = function(s)
              if s[1] then
                ms.read(s[1])
              end
            end,
          },
        })
      end, { desc = "session fuzzy" })

      -- DELETE: <leader>sd
      vim.keymap.set("n", "<leader>sd", function()
        local sessions = get_sessions()
        if #sessions == 0 then
          return
        end
        require("fzf-lua").fzf_exec(sessions, {
          prompt = "Delete> ",
          actions = {
            ["default"] = function(s)
              if s[1] then
                ms.delete(s[1])
              end
            end,
          },
        })
      end, { desc = "session delete" })

      -- INFO: <leader>si
      vim.keymap.set("n", "<leader>si", function()
        local cur = current_session()
        print(cur and cur ~= "" and ("Current: " .. cur) or "No session")
        print("Total: " .. #get_sessions())
      end, { desc = "session info" })
    end,
  },
}
