-- user/config/server/Web/gopls.lua
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = vim.fs.root(0, { "go.mod", "go.work", ".git" }),
  settings = {
    gopls = {
      env = {
        GOPATH = vim.fn.expand("$HOME/go"),
        GOROOT = vim.fn.expand("$PREFIX/lib/go"),
      },
      analyses = { unusedparams = true, shadow = false, unusedwrite = false, useany = false },
      completeUnimported = true,
      completionBudget = "100ms",
      matcher = "Fuzzy",
      deepCompletion = false,
      semanticTokens = false,
      staticcheck = false,
      hints = {
        assignVariableTypes = false,
        compositeLiteralFields = false,
        compositeLiteralTypes = false,
        constantValues = false,
        functionTypeParameters = false,
        parameterNames = false,
        rangeVariableTypes = false,
      },
      codelenses = {
        generate = false,
        gc_details = false,
        test = false,
        tidy = false,
      },
    },
  },
})
vim.lsp.enable("gopls")
