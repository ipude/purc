-- user/config/server/LowLevel/rust_analyzer.lua
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml" },
  single_file_support = false,
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = false, buildScripts = { enable = false }, loadOutDirsFromCheck = false },
      check = { command = "check", extraArgs = { "--no-deps" } },
      procMacro = { enable = false, attributes = { enable = false } },
      diagnostics = {
        enable = true,
        refresh = { workspace = { enable = false } },
        disabled = { "unresolved-proc-macro", "unresolved-macro-call" },
        experimental = { enable = false },
      },
      cachePriming = { enable = false},
      checkOnSave = false,
      files = { excludeDirs = { ".git" }, watcher = "client" },
    },
  },
})
vim.lsp.enable("rust_analyzer")
