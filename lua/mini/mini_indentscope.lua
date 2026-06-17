require("mini.indentscope").setup({
  draw = {
    delay = 50,
    animation = require("mini.indentscope").gen_animation.none(),
  },

  mappings = {
    -- Textobjects
    object_scope = "is",
    object_scope_with_border = "as",

    -- Motions (jump to respective border line; if not present - body line)
    goto_top = "[s",
    goto_bottom = "]s",
  },
  symbol = "│", -- matches ibl for consistency

  options = {
    try_as_border = true,
    indent_at_cursor = true,
  },
})
vim.api.nvim_set_hl(0, "IblIndent", { link = "NonText" })
vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { link = "NonText" })
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "IblIndent", { link = "NonText" })
    vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { link = "NonText" })
  end,
})
