-- ============================================
-- BUFFERS
-- ============================================
vim.keymap.set('n', '<leader>bs', '<Cmd>w<CR>',       { desc = 'Buffer Save [Only for Oil etc buffers]' })
vim.keymap.set('n', '<leader>bc', '<Cmd>%d<CR>',      { desc = 'Buffer Remove data [!RISKY!]' })
vim.keymap.set('n', '<leader>bd', '<Cmd>bdelete<CR>', { desc = 'Buffer Close [SAFE]' })
vim.keymap.set('n', '<leader>bb', function() require('fzf-lua').buffers() end, { desc = 'Pick buffer' })

-- ============================================
-- GIT
-- ============================================
vim.keymap.set('n', '<leader>lg', '<Cmd>LazyGit<CR>', { desc = 'LazyGit' })
vim.keymap.set('n', '<leader>Gl', '<Cmd>LazyGit<CR>', { desc = 'LazyGit' })

-- ============================================
-- NOTIFICATIONS
-- ============================================
vim.keymap.set('n', '<leader>hn', '<Cmd>lua MiniNotify.show_history()<CR>', { desc = 'Notification History' })

-- ============================================
-- RELOAD
-- ============================================
vim.keymap.set('n', '<leader>rr', '<Cmd>mksession! Session.vim | restart source Session.vim<cr>', { desc = 'Restart (Save & Restore Session)' })
vim.keymap.set('n', '<leader>rs', '<Cmd>restart<cr>',        { desc = 'Restart Safely (Fails if Unsaved)' })
vim.keymap.set('n', '<leader>rf', '<Cmd>restart +qall!<cr>', { desc = 'Restart & Discard Unsaved Changes' })

-- ============================================
-- QUIT
-- ============================================
vim.keymap.set('n', '<leader>qq',  '<Cmd>q<CR>',   { desc = 'Quit' })
vim.keymap.set('n', '<leader>qfq', '<Cmd>q!<CR>',  { desc = 'Force Quit' })
vim.keymap.set('n', '<leader>qfa', '<Cmd>qa<CR>',  { desc = 'Quit All' })
vim.keymap.set('n', '<leader>qfw', '<Cmd>qa!<CR>', { desc = 'Force Quit All' })

-- ============================================
-- TOGGLES
-- ============================================
vim.keymap.set('n', '<leader>un', '<Cmd>set number!<CR>',         { desc = 'Toggle Line Numbers' })
vim.keymap.set('n', '<leader>ur', '<Cmd>set relativenumber!<CR>', { desc = 'Toggle Relative Numbers' })
vim.keymap.set('n', '<leader>uw', '<Cmd>set wrap!<CR>',           { desc = 'Toggle Word Wrap' })
vim.keymap.set('n', '<leader>uc', '<Cmd>set cursorline!<CR>',     { desc = 'Toggle Cursor Line' })
vim.keymap.set('n', '<leader>uh', '<Cmd>set hlsearch!<CR>',       { desc = 'Toggle Highlight Search' })

-- ============================================
-- SAVE
-- ============================================
vim.keymap.set('n', '<leader>ws',  '<Cmd>wall<CR>',   { desc = 'Save All' })
vim.keymap.set('n', '<leader>wq',  '<Cmd>wq<CR>',     { desc = 'Save & Quit' })
vim.keymap.set('n', '<leader>wfs', '<Cmd>w!<CR>',     { desc = 'Force Save' })
vim.keymap.set('n', '<leader>wfS', '<Cmd>wall!<CR>',  { desc = 'Force Save All' })
vim.keymap.set('n', '<leader>wfa', '<Cmd>wqall!<CR>', { desc = 'Force Save & Quit All' })

-- ============================================
-- YANK
-- ============================================
vim.keymap.set('n', '<leader>ya', '<Cmd>%y+<CR>',                    { desc = 'Yank All' })
vim.keymap.set('n', '<leader>yp', "<Cmd>let @+ = expand('%:p')<CR>", { desc = 'Yank File Path' })
vim.keymap.set('n', '<leader>yf', "<Cmd>let @+ = expand('%:t')<CR>", { desc = 'Yank File Name' })

-- ============================================
-- LAZY
-- ============================================
vim.keymap.set('n', '<leader>llp', '<Cmd>Lazy profile<CR>', { desc = 'Lazy Profile' })
vim.keymap.set('n', '<leader>llu', '<Cmd>Lazy update<CR>',  { desc = 'Lazy Update' })
vim.keymap.set('n', '<leader>lls', '<Cmd>Lazy sync<CR>',    { desc = 'Lazy Sync' })

-- ============================================
-- LSP SERVER
-- ============================================
vim.keymap.set('n', '<leader>lsi', '<Cmd>LspInfo<CR>',    { desc = 'LSP Info' })
vim.keymap.set('n', '<leader>lsl', '<Cmd>LspLog<CR>',     { desc = 'LSP Log' })
vim.keymap.set('n', '<leader>lsr', '<Cmd>LspRestart<CR>', { desc = 'LSP Restart' })

-- ============================================
-- VISUAL MODE
-- ============================================
vim.keymap.set({ 'v', 'x' }, '<leader>y', '"+y', { desc = 'Yank to Clipboard' })
