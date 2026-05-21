return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },

  keys = {
    { 'zR', function() require('ufo').openAllFolds()  end, desc = 'Open all folds'  },
    { 'zM', function() require('ufo').closeAllFolds() end, desc = 'Close all folds' },
    { 'K',  function()
        local ufo = require('ufo')
        if not ufo.peekFoldedLinesUnderCursor() then
          vim.lsp.buf.hover()
        end
      end, desc = 'Peek fold / LSP hover' },
  },

  init = function()
    vim.opt.foldlevel      = 99
    vim.opt.foldlevelstart = 99
    vim.opt.foldenable     = true
    -- vim.opt.foldcolumn     = '1'
    vim.opt.fillchars:append({
      foldopen  = '▾',
      foldclose = '▸',
      foldsep   = ' ',
      fold      = ' ',
    })
  end,

  config = function()
    require('ufo').setup({
      provider_selector = function(_, filetype)
        local overrides = {
          python   = { 'treesitter', 'indent' },
          markdown = { 'treesitter' },
          yaml     = { 'indent' },
          ['']     = { 'indent' },
        }
        return overrides[filetype] or { 'lsp', 'treesitter', 'indent' }
      end,

      fold_virt_text_handler = function(result, _, _, colwidth, truncate)
        local suffix = ('  ··· %d lines ···'):format(result.end_row - result.start_row)
        local target = colwidth - vim.fn.strdisplaywidth(suffix)
        local chunks, width = {}, 0

        for _, v in ipairs(result.virtual_text) do
          local text, hl = v[1], v[2]
          local w = vim.fn.strdisplaywidth(text)
          if width + w > target then
            table.insert(chunks, { truncate(text, target - width), hl })
            break
          end
          table.insert(chunks, { text, hl })
          width = width + w
        end

        table.insert(chunks, { suffix, 'Comment' })
        return chunks
      end,

      preview = {
        win_config = { border = 'rounded', winblend = 8, maxheight = 20 },
        mappings   = { scrollU = '<C-u>', scrollD = '<C-d>' },
      },
    })
  end,
}
