require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    python = { "black" },
    lua = { "stylua" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    go = { "gofmt" },
    rust = { "rustfmt" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    toml = { "taplo" },
  },

  default_format_opts = { lsp_format = "fallback" },
  format_on_save = nil,
})
-- Global variable to track formatter state (enabled by default)
vim.g.conform_enabled = true
