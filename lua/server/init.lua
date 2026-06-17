-- Always load these (shared LSP base config)
require("server.diagnostic")
require("server.lsp")
require("server.map")

-- Load each server only when its filetype is opened
local ft_servers = {
  lua = "server.HighLevel.lua_ls",
  python = "server.HighLevel.pyright",
  c = "server.LowLevel.clang",
  cpp = "server.LowLevel.clang",
  rust = "server.LowLevel.rust_analyzer",
  json = "server.Utilities.jsonls",
  css = "server.Web.css_ls",
  scss = "server.Web.css_ls",
  html = "server.Web.html",
  typescript = "server.Web.ts_ls",
  javascript = "server.Web.ts_ls",
  go = "server.Web.gopls",
}

for ft, mod in pairs(ft_servers) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = ft,
    once = true,
    callback = function()
      require(mod)
    end,
  })
end
