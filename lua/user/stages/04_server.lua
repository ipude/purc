-- Defer everything until a file is actually opened
vim.api.nvim_create_autocmd('BufReadPre', {
    once = true,
    callback = function()
        require('user.config.tools.lsp')
        require('user.config.server.map')
        require('user.config.server.HighLevel.lua_ls')
        require('user.config.server.HighLevel.pyright')
        require('user.config.server.LowLevel.clang')
        require('user.config.server.LowLevel.rust_analyzer')
        require('user.config.server.Utilities.jsonls')
        require('user.config.server.Web.css_ls')
        require('user.config.server.Web.html')
        require('user.config.server.Web.ts_ls')
        require('user.config.server.Web.gopls')
    end,
})
