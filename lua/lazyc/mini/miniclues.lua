local function setup_miniclues()
  require("mini.clue").setup({
    -- Delay before the clue window appears (ms)
    window = {
      delay = 50,
      config = {
        border = "rounded",
        -- winblend = 0 is the default, omit if not needed
      },
    },

    -- Triggers: which key presses activate the clue popup
    triggers = {
      -- Leader key (normal, visual, operator-pending)
      { mode = "n", keys = "<Leader>" },
      { mode = "x", keys = "<Leader>" },
      { mode = "o", keys = "<Leader>" },

      -- Local leader
      { mode = "n", keys = "<LocalLeader>" },
      { mode = "x", keys = "<LocalLeader>" },

      -- Custom fake leaders
      { mode = "n", keys = ";" },
      { mode = "x", keys = ";" },
      { mode = "n", keys = "|" },
      { mode = "x", keys = "|" },
      { mode = "n", keys = "=" },
      { mode = "x", keys = "=" },
      { mode = "n", keys = "," },
      { mode = "x", keys = "," },

      -- Built-in useful triggers
      { mode = "n", keys = "g" },
      { mode = "x", keys = "g" },
      { mode = "n", keys = "[" },
      { mode = "n", keys = "]" },
      { mode = "n", keys = "<C-w>" },
      { mode = "n", keys = "z" },
      { mode = "x", keys = "z" },
      { mode = "i", keys = "<C-x>" },
      { mode = "n", keys = "'" },
      { mode = "n", keys = "`" },
      { mode = "n", keys = '"' },
      { mode = "i", keys = "<C-r>" },
      { mode = "c", keys = "<C-r>" },
      { mode = "x", keys = "[" },
      { mode = "x", keys = "]" },
    },

    clues = {
      -- Built-in clue generators
      require("mini.clue").gen_clues.builtin_completion(),
      require("mini.clue").gen_clues.g(),
      require("mini.clue").gen_clues.marks(),
      require("mini.clue").gen_clues.registers(),
      require("mini.clue").gen_clues.windows(),
      require("mini.clue").gen_clues.z(),
      require("mini.clue").gen_clues.square_brackets(),

      -- ============================================
      -- TOP-LEVEL GROUP DEFINITIONS
      -- ============================================
      { mode = "n", keys = "<Leader>b", desc = "󰓩 Buffers" },
      { mode = "n", keys = "<Leader>c", desc = "󱘗 Filetype Commands" },
      { mode = "n", keys = "<Leader>d", desc = "󰃤 Diagnostics" },
      { mode = "n", keys = "<Leader>e", desc = "󰍉 Fzf Flexible" },
      { mode = "n", keys = "<Leader>f", desc = "󰍉 Find Files" },
      { mode = "n", keys = "<Leader>g", desc = "󰍉 Grep" },
      { mode = "n", keys = "<Leader>n", desc = "󰊢 Neogit" },
      { mode = "n", keys = "<Leader>h", desc = "󰋚 History" },
      { mode = "n", keys = "<Leader>l", desc = "󰒲 Lazy / LSP" },
      { mode = "n", keys = "<Leader>o", desc = "󰇥 Yazi" },
      { mode = "n", keys = "<Leader>p", desc = "󰅇 Paste" },
      { mode = "n", keys = "<Leader>q", desc = "󰗼 Quit" },
      { mode = "n", keys = "<Leader>r", desc = "󰑓 Reload" },
      { mode = "n", keys = "<Leader>s", desc = "󰆓 Sessions" },
      { mode = "n", keys = "<Leader>t", desc = "󰉿 Format" },
      { mode = "n", keys = "<Leader>u", desc = "󰔡 Toggles" },
      { mode = "n", keys = "<Leader>w", desc = "󰆓 Advanced Save" },
      { mode = "n", keys = "<Leader>y", desc = "󰅎 Yank" },
      { mode = "n", keys = "<Leader>z", desc = "󱐋 Code Runner" },

      -- ============================================
      -- SUB-GROUP DEFINITIONS
      -- ============================================
      { mode = "n", keys = "<Leader>fi", desc = "󰍉 Find Files .." },
      { mode = "n", keys = "<Leader>gi", desc = "󰊢 Grep in .." },
      { mode = "n", keys = "<Leader>ll", desc = "󰒲 Lazy" },
      { mode = "n", keys = "<Leader>ls", desc = "󰒍 LSP Server" },
      { mode = "n", keys = "<Leader>qf", desc = "󰗼 Force Quit" },
      { mode = "n", keys = "<Leader>wf", desc = "󰆓 Force Save" },

      -- Visual mode groups
      { mode = "x", keys = "<Leader>r", desc = "󰛔 Replace" },
      { mode = "v", keys = "<Leader>r", desc = "󰛔 Replace" },
    },
  })
  -- ============================================
  -- ENABLE MINI.CLUE IN SPECIAL BUFFERS
  -- ============================================
  local special_ft = { "oil", "toggleterm", "neo-tree", "lazy", "mason" }
  local special_bt = { "terminal", "acwrite", "nofile", "prompt" }

  local function maybe_enable(buf)
    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype
    local ft_match = vim.tbl_contains(special_ft, ft)
    local bt_match = vim.tbl_contains(special_bt, bt)

    if ft_match or bt_match then
      vim.schedule(function()
        pcall(require("mini.clue").enable_buf_triggers, buf)
      end)
    end
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "TermOpen" }, {
    callback = function(ev)
      maybe_enable(ev.buf)
    end,
  })
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.defer_fn(setup_miniclues, 50)
  end,
})
