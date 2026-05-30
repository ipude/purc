vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    if client.name == 'marksman' or client.name == 'gdscript' then
      client.server_capabilities.documentHighlightProvider = false
    end

    local opts = { buffer = ev.buf, silent = true }

    vim.keymap.set('n', 'K', function()
      vim.lsp.buf.hover()
    end, opts)

    vim.keymap.set('i', '<C-h>', function()
      vim.lsp.buf.signature_help()
    end, opts)
  end,
})

vim.keymap.set('n', '<leader>ui', function()
  local buf = vim.api.nvim_get_current_buf()
  vim.lsp.inlay_hint.enable(
    not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }),
    { bufnr = buf }
  )
end, { desc = 'Toggle Inlay Hints' })
