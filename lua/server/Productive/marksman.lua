-- user/config/server/Productive/marksman.lua
vim.lsp.config("marksman", {
  cmd = { "marksman", "server" },
  filetypes = { "markdown", "markdown.mdx" },
  flags = { debounce_text_changes = 300 },
})
vim.lsp.enable("marksman")
