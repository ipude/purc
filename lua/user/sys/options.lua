-- ================================================
-- load_first.lua
-- ================================================
-- Leader MUST be before everything else
vim.g.mapleader              = ' '
vim.g.maplocalleader         = "'"
_G.map                       = vim.keymap.set
-- ================================================
-- Provider disable (speeds up startup)
-- ================================================
vim.g.loaded_python_provider = 0
vim.g.loaded_ruby_provider   = 0
vim.g.loaded_perl_provider   = 0

vim.o.updatetime             = 300 -- not 0, that hammers swapfile/cursorhold
vim.o.ttimeoutlen            = 0
vim.o.timeoutlen             = 300
vim.o.swapfile               = true
vim.o.confirm                = true
-- lazyredraw is deprecated in 0.10+, causes issues with some plugins
-- vim.o.lazyredraw = true
-- ================================================
-- Indent and Movement
-- ================================================
vim.o.startofline            = false
vim.o.breakindent            = true
vim.o.tabstop                = 4
vim.o.shiftwidth             = 4
vim.o.softtabstop            = 4
vim.o.expandtab              = true
vim.keymap.set('n', '<Up>', 'g<Up>')
vim.keymap.set('n', '<Down>', 'g<Down>')
-- ================================================
-- UI & Display
-- ================================================
vim.o.cmdheight      = 1
vim.o.showcmd        = false
vim.opt.splitright   = true
vim.opt.splitbelow   = true
vim.o.ignorecase     = true
vim.o.smartcase      = true
vim.o.incsearch      = true
vim.o.hlsearch       = true
vim.o.winborder      = 'rounded'
vim.o.winminheight   = 0
vim.o.number         = true
vim.o.relativenumber = true
vim.o.cursorline     = true
vim.o.termguicolors  = true
vim.o.signcolumn     = 'yes'
vim.o.showtabline    = 2
vim.o.scrolloff      = 8
vim.o.sidescrolloff  = 8
vim.opt.fillchars:append({ eob = ' ' })
-- ================================================
-- Bell
-- ================================================
vim.o.visualbell = false
vim.o.errorbells = false
-- ================================================
-- Osc 52
-- ================================================
vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  },
}
-- explicit keymaps only, same as before
vim.keymap.set('n', '<leader>yc', function()
  vim.fn.setreg('+', vim.fn.getreg('"'))
end, { desc = 'Copy yank register to system clipboard' })
-- ================================================
-- End
-- ================================================
