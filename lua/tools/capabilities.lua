-- user/config/tools/capabilities.lua
local M = {}

M.capabilities = nil

function M.get()
  if M.capabilities then
    return M.capabilities
  end

  local base = vim.lsp.protocol.make_client_capabilities()

  -- merge in the extras you had
  base.textDocument.completion.completionItem =
    vim.tbl_deep_extend("force", base.textDocument.completion.completionItem or {}, {
      snippetSupport = true,
      insertReplaceSupport = true,
      labelDetailsSupport = true,
      commitCharactersSupport = true,
      deprecatedSupport = true,
      preselectSupport = true,
      documentationFormat = { "markdown", "plaintext" },
      resolveSupport = {
        properties = { "documentation", "detail", "additionalTextEdits" },
      },
    })
  base.workspace.didChangeWatchedFiles = {
    dynamicRegistration = true,
    relativePatternSupport = true,
  }

  local ok, blink = pcall(require, "blink.cmp")
  M.capabilities = ok and blink.get_lsp_capabilities(base) or base

  return M.capabilities
end

return M
