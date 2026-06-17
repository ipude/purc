-- Termux only
vim.env.PATH = table.concat({
  "/data/data/com.termux/files/usr/bin",
  vim.env.HOME .. "/.cargo/bin",
  vim.env.HOME .. "/.npm-global/bin",
  vim.env.HOME .. "/go/bin",
  vim.env.PATH,
}, ":")

vim.env.GOPATH = vim.env.HOME .. "/go"
vim.env.GOROOT = "/data/data/com.termux/files/usr/lib/go"
