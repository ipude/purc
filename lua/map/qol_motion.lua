-- =======================================
-- disable accidental macro recording on q
-- =======================================
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

-- ==============================
-- Insert map
-- ==============================
vim.keymap.set({ "i", "v" }, "<End>", "g$")
vim.keymap.set("i", "<End>", "<C-o>g$")
vim.keymap.set("i", "<Up>", "<C-o>gk")
vim.keymap.set("i", "<Down>", "<C-o>gj")

-- ==============================
-- Normal and visual
-- ==============================
vim.keymap.set({"n", "v"}, "<Up>", "g<Up>")
vim.keymap.set({"n", "v"}, "<Down>", "g<Down>")

-- ==============================
-- Fast quit
-- ==============================
vim.keymap.set("n", "<C-q>", "<nop>")
vim.keymap.set("n", "<C-q>", "<cmd>q<cr>")
