vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
    "--header-insertion-decorators",
    "--all-scopes-completion",
    "--fallback-style=LLVM",
    "--pch-storage=disk",
    "--ranking-model=decision_forest",
    "-j=4",
    "--log=error",
    "--enable-config",
    "--offset-encoding=utf-16",
  },

  filetypes = {
    "c",
    "cpp",
    "objc",
    "objcpp",
    "cuda",
    "proto",
  },

  root_markers = {
    "compile_commands.json",
    "compile_flags.txt",
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "CMakeLists.txt",
    "Makefile",
    "meson.build",
    "build.ninja",
    ".git",
  },

  capabilities = (function()
    local caps = vim.lsp.protocol.make_client_capabilities()
    caps.textDocument.completion.completionItem.snippetSupport = true
    caps.textDocument.completion.completionItem.resolveSupport = {
      properties = { "documentation", "detail", "additionalTextEdits" },
    }
    return caps
  end)(),

  settings = {},
})

vim.lsp.enable("clangd")
