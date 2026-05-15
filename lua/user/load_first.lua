-- -- Don't remove from here
-- vim.api.nvim_create_autocmd('FileType', {
-- 	pattern = '*',
-- 	callback = function()
-- 		-- Disable smart/c-indenting logic
-- 		vim.opt_local.smartindent = true
-- 		vim.opt_local.cindent = true
-- 		vim.opt_local.indentexpr = ''
--
-- 		-- Set 4-space indentation
-- 		vim.opt_local.tabstop = 4 -- A tab is 4 spaces
-- 		vim.opt_local.shiftwidth = 4 -- Indent/outdent by 4 spaces
-- 		vim.opt_local.softtabstop = 4 -- <Tab> in insert mode inserts 4 spaces
-- 		vim.opt_local.expandtab = true -- Turn tabs into spaces
-- 	end,
-- })

-- ================================================
-- Speed & everyday features
-- ================================================
vim.o.visualbell = false
vim.o.errorbells = false
vim.o.updatetime = 0
vim.o.ttimeoutlen = 0
vim.o.timeoutlen = 100
vim.o.lazyredraw = true
vim.o.swapfile = true
vim.o.confirm = true
-- ================================================
-- Indent and Movement
-- ================================================
vim.o.startofline = false
vim.o.breakindent = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.keymap.set('n', '<Up>', 'g<Up>')
vim.keymap.set('n', '<Down>', 'g<Down>')
-- ================================================
-- Leader declaration
-- ================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = "'" -- Local leader
_G.map = vim.keymap.set
-- ================================================
-- UI & Display
-- ================================================
vim.opt.splitright = true      -- new splits open right
vim.opt.splitbelow = true      -- new splits open below
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.winborder = 'rounded'  -- applies to all floats automatically (0.11+)
vim.o.winminheight = 0       -- allows splits to shrink to 0 height when pinned
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.termguicolors = true
vim.o.signcolumn = 'yes'
vim.o.showtabline = 2
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.opt.fillchars:append({ eob = ' ' })
-- ================================================
-- Needed
-- ================================================
vim.lsp.set_log_level('warn')
vim.g.loaded_python_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
-- ================================================
-- Fold
-- ================================================
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.lsp.foldexpr()'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
-- ================================================
-- ================================================


