-- ==========================================
-- These must load before
-- ==========================================
require("server.diagnostic")
require("server.map")
-- ==========================================
-- End
-- ==========================================


-- ==========================================
-- Lsp server require calls start from here
-- ==========================================
local ft_servers = {
  lua = "server.HighLevel.lua_ls",
  python = "server.HighLevel.pyright",
  c = "server.LowLevel.clang",
  cpp = "server.LowLevel.clang",
  rust = "server.LowLevel.rust_analyzer",
  zig = "server.LowLevel.zls",
  json = "server.Utilities.jsonls",
  css = "server.Web.css_ls",
  scss = "server.Web.css_ls",
  html = "server.Web.html",
  typescript = "server.Web.ts_ls",
  javascript = "server.Web.ts_ls",
  go = "server.Web.gopls",
}

local function load_server(ft)
  local mod = ft_servers[ft]
  if mod then
    require(mod)
  end
end
local lsp_core_loaded = false
local function ensure_lsp_core()
  if lsp_core_loaded then
    return
  end
  lsp_core_loaded = true
  require("server.lsp")
  require("server.log")
end
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.defer_fn(function()
      -- phase 1: catch whatever was opened before VimEnter (cli args, session restore, etc.)
      local seen = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          local ft = vim.bo[buf].filetype
          if ft_servers[ft] and not seen[ft] then
            seen[ft] = true
            ensure_lsp_core()
            load_server(ft)
          end
        end
      end

      -- phase 2: from here on, lazily load on demand
      vim.api.nvim_create_autocmd("FileType", {
        pattern = vim.tbl_keys(ft_servers),
        callback = function(args)
          ensure_lsp_core()
          load_server(args.match)
        end,
      })
    end, 50)
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})
-- ==========================================
-- End
-- ==========================================
