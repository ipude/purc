-- init.lua

-------------------------------------------------------------------------------
-- F12: listed terminal
-------------------------------------------------------------------------------
local listed_term = { buf = nil }

local function listed_buf_exists()
  return listed_term.buf ~= nil and vim.api.nvim_buf_is_valid(listed_term.buf)
end

local function listed_toggle()
  if listed_buf_exists() and vim.api.nvim_get_current_buf() == listed_term.buf then
    if #vim.api.nvim_list_tabpages() > 1 then
      vim.cmd("tabclose")
    else
      vim.cmd("enew")
    end
    return
  end

  if listed_buf_exists() then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == listed_term.buf then
        vim.api.nvim_set_current_win(win)
        vim.cmd("startinsert")
        return
      end
    end
    vim.cmd("tabnew")
    local blank = vim.api.nvim_get_current_buf()
    vim.bo[blank].bufhidden = "wipe"
    vim.api.nvim_win_set_buf(0, listed_term.buf)
  else
    vim.cmd("tabnew")
    local blank = vim.api.nvim_get_current_buf()
    vim.bo[blank].bufhidden = "wipe"
    vim.cmd("terminal")
    listed_term.buf = vim.api.nvim_get_current_buf()
    vim.bo[listed_term.buf].buflisted = false
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
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
      vim.schedule(fn)
    else
      fn()
    end
  end
end

for _, mode in ipairs({ "n", "i", "t" }) do
  vim.keymap.set(mode, "<F12>", with_escape(mode, listed_toggle), { desc = "Toggle listed terminal", silent = true })
end

-------------------------------------------------------------------------------
-- TermOpen autocmd
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(ev)
    vim.keymap.set("t", "<S-Tab>", "<C-\\><C-n>", { buffer = ev.buf, desc = "Exit terminal mode" })
  end,
})
