-- ===========================
-- 02_uiCore
-- ===========================

-- Must be at startup (colorscheme/visuals needed before first render)

vim.schedule(function()
    require('user.ui.core.statusline')
    require('user.ui.core.ibl') -- indent lines
end)
