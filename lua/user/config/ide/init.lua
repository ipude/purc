-- Autosave: needs to be active immediately
vim.schedule(function()
    require('user.config.ide.ide.module_require.autosave')
    require('user.config.ide.ide.module_require.run')
    require('user.config.ide.ide.undotree')
end)
