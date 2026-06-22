-- ============================================
-- BUFFERS
-- ============================================
vim.keymap.set("n", "<Leader>bs", "<Cmd>w<CR>", { desc = "Buffer Save [Only for Oil etc buffers]" })
vim.keymap.set("n", "<Leader>bc", "<Cmd>%d<CR>", { desc = "Buffer Remove data [!RISKY!]" })
vim.keymap.set("n", "<Leader>bd", "<Cmd>bdelete<CR>", { desc = "Buffer Close [SAFE]" })
vim.keymap.set("n", "<Leader>bb", function()
  vim.cmd("FzfLua buffers")
end, { desc = "Pick buffer" })
-- ============================================
-- RELOAD
-- ============================================
vim.keymap.set(
  "n",
  "<Leader>rr",
  "<Cmd>mksession! Session.vim | restart source Session.vim<CR>",
  { desc = "Restart (Save & Restore Session)" }
)
vim.keymap.set("n", "<Leader>rs", "<Cmd>restart<CR>", { desc = "Restart Safely (Fails if Unsaved)" })
vim.keymap.set("n", "<Leader>rf", "<Cmd>restart +qall!<CR>", { desc = "Restart & Discard Unsaved Changes" })

-- ============================================
-- QUIT
-- ============================================
vim.keymap.set("n", "<Leader>qq", "<Cmd>q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<Leader>qfq", "<Cmd>q!<CR>", { desc = "Force Quit" })
vim.keymap.set("n", "<Leader>qfa", "<Cmd>qa<CR>", { desc = "Quit All" })
vim.keymap.set("n", "<Leader>qfw", "<Cmd>qa!<CR>", { desc = "Force Quit All" })

-- ============================================
-- TOGGLES
-- ============================================
vim.keymap.set("n", "<Leader>un", "<Cmd>set number!<CR>", { desc = "Line Numbers" })
vim.keymap.set("n", "<Leader>ur", "<Cmd>set relativenumber!<CR>", { desc = "Relative Numbers" })
vim.keymap.set("n", "<Leader>uw", "<Cmd>set wrap!<CR>", { desc = "Word Wrap" })
vim.keymap.set("n", "<Leader>uc", "<Cmd>set cursorline!<CR>", { desc = "Cursor Line" })
vim.keymap.set("n", "<Leader>uh", "<Cmd>set hlsearch!<CR>", { desc = "Highlight Search" })
-- ============================================
-- SAVE
-- ============================================
vim.keymap.set("n", "<Leader>ws", "<Cmd>wall<CR>", { desc = "Save All" })
vim.keymap.set("n", "<Leader>wq", "<Cmd>wq<CR>", { desc = "Save & Quit" })
vim.keymap.set("n", "<Leader>wfs", "<Cmd>w!<CR>", { desc = "Force Save" })
vim.keymap.set("n", "<Leader>wfS", "<Cmd>wall!<CR>", { desc = "Force Save All" })
vim.keymap.set("n", "<Leader>wfa", "<Cmd>wqall!<CR>", { desc = "Force Save & Quit All" })

-- ============================================
-- YANK
-- ============================================
vim.keymap.set("n", "<Leader>ya", "<Cmd>%y+<CR>", { desc = "Yank All" })
vim.keymap.set("n", "<Leader>yp", "<Cmd>let @+ = expand('%:p')<CR>", { desc = "Yank File Path" })
-- ============================================
-- LAZY
-- ============================================
vim.keymap.set("n", "<Leader>lp", "<Cmd>Lazy profile<CR>", { desc = "Profile" })
vim.keymap.set("n", "<Leader>li", "<Cmd>Lazy install<CR>", { desc = "Install" })
vim.keymap.set("n", "<Leader>lr", "<Cmd>Lazy restore<CR>", { desc = "Restore" })
vim.keymap.set("n", "<Leader>ls", "<Cmd>Lazy sync<CR>", { desc = "Sync" })
vim.keymap.set("n", "<Leader>lh", "<Cmd>Lazy home<CR>", { desc = "Home" })
vim.keymap.set("n", "<Leader>lu", "<Cmd>Lazy update<CR>", { desc = "Update" })
-- ============================================
-- LSP SERVER
-- ============================================
vim.keymap.set("n", ";li", "<Cmd>e ~/.local/state/nvim/lsp.log<CR>", { desc = "Lsp log" })

-- ============================================
-- VISUAL MODE
-- ============================================
vim.keymap.set({ "v", "x" }, "<Leader>y", '"+y', { desc = "Yank to Clipboard" })

