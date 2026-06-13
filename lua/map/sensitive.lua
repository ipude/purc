-- This map is ment to intercept <UP> and <DOWN> keys in Normal and Insert mode.
--

vim.keymap.set({'n', 'i'}, '<Up>', '<Nop>')
vim.keymap.set({'n', 'i'}, '<Down>', '<Nop>')

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "o", "r" })
  end,
})
