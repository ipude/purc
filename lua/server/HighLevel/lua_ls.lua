-- user/config/server/HighLevel/lua_ls.lua
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" }, -- ← this is what's missing
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".git" },
  settings = {
    Lua = {
      runtime = { version = "Lua 5.4", path = vim.split(package.path, ";") },
      diagnostics = {
        enable = true,
        globals = { "vim", "describe", "it", "before_each", "after_each" },
        disable = { "trailing-space" },
        unusedLocalExclude = { "_*" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
        maxPreload = 2000,
        preloadFileSize = 500,
      },
      completion = { callSnippet = "Replace", showWord = "Disable" },
      hint = { enable = true },
      telemetry = { enable = false },
      semantic = { enable = false },
    },
  },
  handlers = { ["$/progress"] = function() end },
})
vim.lsp.enable("lua_ls")
