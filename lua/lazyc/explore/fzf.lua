-- ============================
-- Fzf-lua setup
-- ============================
local function setup_fzf()
  require("fzf-lua").setup({
    winopts = {
      height = 0.85,
      width = 0.80,
      row = 0.35,
      col = 0.50,
      border = "rounded",
      wrap = true,
      preview = {
        delay = 0,
        border = "rounded",
        wrap = "wrap",
        hidden = "nohidden",
        vertical = "down:45%",
        horizontal = "right:60%",
        layout = "flex",
        flip_columns = 120,
      },
    },
    -- actions = { ["ctrl-g"] = require("fzf-lua").actions.grep_lgrep },
    fzf_opts = {
      ["--wrap"] = true,
    },
    fzf_colors = {
      ["fg"] = { "fg", "Normal" },
      ["bg"] = { "bg", "Normal" },
      ["fg+"] = { "fg", "Normal" },
      ["bg+"] = { "bg", "Visual" },
      ["hl"] = { "fg", "Identifier" },
      ["hl+"] = { "fg", "Statement" },
      ["prompt"] = { "fg", "Keyword" },
      ["pointer"] = { "fg", "Type" },
      ["marker"] = { "fg", "Type" },
      ["header"] = { "fg", "Title" },
      ["info"] = { "fg", "Special" },
    },
    files = {
      prompt = " ",
      multiprocess = true,
      git_icons = true,
      file_icons = true,
      color_icons = true,
      fd_opts = "--color=never --type f --hidden --follow --exclude .git",
    },
    grep = {
      prompt = " ",
      input_prompt = "Grep  ",
      multiprocess = true,
      git_icons = true,
      file_icons = true,
      color_icons = true,
      rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case -g '!.git'",
    },
  })
end

-- Setup fzf-lua on VimEnter
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(setup_fzf)
  end,
})

require("lazyc.explore.fzf_map")
