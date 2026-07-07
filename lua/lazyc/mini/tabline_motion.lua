vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>tabprevious<cr>", { silent = true, desc = "Previous tab" })
vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>tabnext<cr>", { silent = true, desc = "Next tab" })

vim.keymap.set({"n", "v", "i"}, "<C-c>", "<cmd>tabonly!<cr>", {silent = true, desc = "Close zombie tabs"})
