-- user/config/server/LowLevel/rust_analyzer.lua
local map = vim.keymap.set
vim.lsp.config('rust_analyzer', {
  cmd           = { 'rust-analyzer' },
  filetypes     = { 'rust' },
  root_markers  = { 'Cargo.toml' },
  single_file_support = false,
  settings = {
    ['rust-analyzer'] = {
      cargo        = { allFeatures = false, buildScripts = { enable = false } },
      check        = { command = 'clippy', extraArgs = { '--no-deps' } },
      procMacro    = { enable = true, attributes = { enable = true } },
      diagnostics  = {
        enable = true,
        refresh = { workspace = { enable = false } },
        disabled = { 'unresolved-proc-macro', 'unresolved-macro-call' },
        experimental = { enable = false },
      },
      cachePriming = { enable = true, numThreads = 2 },
      checkOnSave  = true,
      files        = { excludeDirs = { '.git' }, watcher = 'client' },
    },
  },
})
vim.lsp.enable('rust_analyzer')
