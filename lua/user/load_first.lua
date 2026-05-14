-- Don't remove from here
vim.api.nvim_create_autocmd('FileType', {
	pattern = '*',
	callback = function()
		-- Disable smart/c-indenting logic
		vim.opt_local.smartindent = false
		vim.opt_local.cindent = false
		vim.opt_local.indentexpr = ''

		-- Set 4-space indentation
		vim.opt_local.tabstop = 4 -- A tab is 4 spaces
		vim.opt_local.shiftwidth = 4 -- Indent/outdent by 4 spaces
		vim.opt_local.softtabstop = 4 -- <Tab> in insert mode inserts 4 spaces
		vim.opt_local.expandtab = true -- Turn tabs into spaces
	end,
})

-- Leader set to space
vim.g.mapleader = ' '
vim.g.maplocalleader = "'" -- Local leader
_G.map = vim.keymap.set
-- UI & Display
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.termguicolors = true
vim.o.signcolumn = 'yes'
vim.o.showtabline = 2
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.opt.fillchars:append({ eob = ' ' })
-- require("user.profiler")
vim.g.loaded_python_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.lsp.set_log_level('warn')

