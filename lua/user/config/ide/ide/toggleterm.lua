-- init.lua

-------------------------------------------------------------------------------
-- F1: unlisted split terminal (f1term)
-------------------------------------------------------------------------------
local split_term = { buf = nil, win = nil }

local function split_buf_exists()
  return split_term.buf ~= nil and vim.api.nvim_buf_is_valid(split_term.buf)
end

local function split_is_open()
  return split_term.win ~= nil and vim.api.nvim_win_is_valid(split_term.win)
end

local function is_f1term(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  return split_buf_exists() and buf == split_term.buf
end

local function split_toggle()
  if split_is_open() then
    vim.api.nvim_win_hide(split_term.win)
    split_term.win = nil
    return
  end

  vim.cmd("botright 15split")
  split_term.win = vim.api.nvim_get_current_win()

  if split_buf_exists() then
    vim.api.nvim_win_set_buf(split_term.win, split_term.buf)
  else
    vim.cmd("terminal")
    split_term.buf = vim.api.nvim_get_current_buf()
    vim.bo[split_term.buf].buflisted = false
    vim.api.nvim_buf_attach(split_term.buf, false, {
      on_detach = function()
        split_term.buf = nil
        split_term.win = nil
      end,
    })
  end

  vim.cmd("startinsert")
end

-------------------------------------------------------------------------------
-- F12: listed terminal (independent, blocked inside f1term)
-------------------------------------------------------------------------------
local listed_term = { buf = nil }

local function listed_buf_exists()
  return listed_term.buf ~= nil and vim.api.nvim_buf_is_valid(listed_term.buf)
end

local function listed_toggle()
  if is_f1term() then
    vim.notify("F12 will not work inside f1term", vim.log.levels.WARN)
    return
  end

  if listed_buf_exists() and vim.api.nvim_get_current_buf() == listed_term.buf then
    vim.cmd("bprevious")
    return
  end

  if listed_buf_exists() then
    vim.api.nvim_win_set_buf(0, listed_term.buf)
  else
    vim.cmd("terminal")
    listed_term.buf = vim.api.nvim_get_current_buf()
    vim.bo[listed_term.buf].buflisted = true
    vim.api.nvim_buf_attach(listed_term.buf, false, {
      on_detach = function()
        listed_term.buf = nil
      end,
    })
  end

  vim.cmd("startinsert")
end

-------------------------------------------------------------------------------
-- Keymaps
-------------------------------------------------------------------------------
local function with_escape(mode, fn)
  return function()
    if mode == "i" or mode == "t" then
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true),
        "n", false
      )
      vim.schedule(fn)
    else
      fn()
    end
  end
end

for _, mode in ipairs({ "n", "i", "t", "v" }) do
  vim.keymap.set(mode, "<F1>", with_escape(mode, split_toggle), { desc = "Toggle split terminal", silent = true })
end

vim.keymap.set("n", "<F12>", listed_toggle, { desc = "Toggle listed terminal", silent = true })
vim.keymap.set("t", "<F12>", function()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true),
    "n", false
  )
  vim.schedule(listed_toggle)
end, { desc = "Toggle listed terminal", silent = true })

-------------------------------------------------------------------------------
-- TermOpen autocmds
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(ev)
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>",
      { buffer = ev.buf, desc = "Exit terminal mode" })
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    if not vim.bo.buflisted then
      vim.cmd("resize 15")
    end
  end,
})
