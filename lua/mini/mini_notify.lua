local queue = {}
local mini_notify = require("mini.notify")

mini_notify.setup({
  content = { format = nil, sort = nil },
  lsp_progress = { enable = false, duration_last = 1000 },
  window = {
    config = {
      border = "rounded",
      anchor = "NE",
      focusable = false,
      zindex = 100,
      style = "minimal",
    },
    winblend = 10,
    max_width_share = 0.35,
    max_height_share = 0.25,
  },
})

-- Replace hijack with real notify
vim.notify = mini_notify.make_notify({
  ERROR = { duration = 10000, hl_group = "DiagnosticError" },
  WARN = { duration = 5000, hl_group = "DiagnosticWarn" },
  INFO = { duration = 3000, hl_group = "DiagnosticInfo" },
  DEBUG = { duration = 3000, hl_group = "DiagnosticHint" },
  TRACE = { duration = 3000, hl_group = "DiagnosticHint" },
})

-- Flush anything that was notified before mini loaded
for _, n in ipairs(queue) do
  vim.notify(n.msg, n.level, n.opts)
end
queue = nil

-- LSP message handler
vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local name = client and client.name or "LSP"
  local levels = { vim.log.levels.ERROR, vim.log.levels.WARN, vim.log.levels.INFO, vim.log.levels.DEBUG }
  vim.notify(string.format("[%s] %s", name, result.message), levels[result.type] or vim.log.levels.INFO)
end
