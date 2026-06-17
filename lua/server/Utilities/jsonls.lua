-- user/config/server/Utilities/jsonls.lua
vim.lsp.config("jsonls", {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json" },
})
vim.lsp.enable("jsonls")
