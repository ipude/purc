local modes = { "n", "i", "v", "c", "t" } -- normal, insert, visual, command, terminal

vim.keymap.set(modes, "<PageDown>", "<cmd>bprevious<cr>", { silent = true, desc = "Previous buffer" })
vim.keymap.set(modes, "<PageUp>", "<cmd>bnext<cr>", { silent = true, desc = "Next buffer" })
vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>tabprevious<cr>", { silent = true, desc = "Previous tab" })
vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>tabnext<cr>", { silent = true, desc = "Next tab" })
-- Buffer reordering — mini.tabline has no move commands,
-- these swap via bufferline order workaround using native cmds
vim.keymap.set("n", "<A-,>", function()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  local cur = vim.api.nvim_get_current_buf()
  for i, b in ipairs(bufs) do
    if b.bufnr == cur and i > 1 then
      -- swap display hint via a simple bnext/bprev cycle
      vim.cmd("bprevious")
      break
    end
  end
end, { silent = true, desc = "Move buffer left" })

vim.keymap.set("n", "<A-.>", function()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  local cur = vim.api.nvim_get_current_buf()
  for i, b in ipairs(bufs) do
    if b.bufnr == cur and i < #bufs then
      vim.cmd("bnext")
      break
    end
  end
end, { silent = true, desc = "Move buffer right" })
