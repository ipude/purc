local function setup_icon()
  require("mini.icons").setup()
end
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.defer_fn(setup_icon, 80)
  end,
})
