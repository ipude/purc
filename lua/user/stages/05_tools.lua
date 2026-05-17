-- ===========================
-- 05_tools
-- ===========================

-- Runs immediately — must be before LSP attaches
require('user.config.tools.diagnostic')
require('user.config.tools.formatter')

-- LspAttach: NO once=true, runs for every buffer that attaches
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        -- Guard so setup only runs once but applies to all buffers
        if not vim.g.lsp_tools_loaded then
            vim.g.lsp_tools_loaded = true
            require('user.config.tools.navic')
        end

        -- navic needs per-buffer attachment
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local ok, navic = pcall(require, 'nvim-navic')
        if ok and client and client.server_capabilities.documentSymbolProvider then
            navic.attach(client, args.buf)
        end
    end,
})

-- InsertEnter: once=true is fine here, these are global setups
vim.api.nvim_create_autocmd('InsertEnter', {
    once = true,
    callback = function()
        require('user.config.tools.luasnip')
        require('user.config.tools.autopairs.autopairs')
    end,
})
