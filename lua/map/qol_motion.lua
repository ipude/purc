-- disable accidental macro recording on q
vim.keymap.set("n", "q", "<nop>")
vim.keymap.set("n", "<M-t>", "<nop>")
vim.keymap.set("n", "<M-r>", function()
  if vim.fn.reg_recording() == "" then
    vim.api.nvim_feedkeys("q", "n", false)
  end
end)

vim.keymap.set("n", "<M-t>", function()
  if vim.fn.reg_recording() ~= "" then
    vim.api.nvim_feedkeys("q", "n", false)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end
end)

vim.keymap.set({ "n", "v" }, "<End>", "g$")
vim.keymap.set("i", "<End>", "<C-o>g$")
vim.keymap.set("n", "k", "g<Up>")
vim.keymap.set("n", "j", "g<Down>")

vim.keymap.set("i", "<Up>", "<C-o>gk")
vim.keymap.set("i", "<Down>", "<C-o>gj")

vim.keymap.set("v", "k", "g<Up>")
vim.keymap.set("v", "j", "g<Down>")
vim.keymap.set("v", "<Up>", "g<Up>")
vim.keymap.set("v", "<Down>", "g<Down>")

vim.keymap.set("n", "<C-q>", "<nop>")
vim.keymap.set("n", "<C-q>", "<cmd>q<cr>")
