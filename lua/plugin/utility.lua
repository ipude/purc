-- ===========================
-- Utility Features
-- ===========================
return {
    {
        'mg979/vim-visual-multi',
        keys = {
            { '<C-n>',   mode = { 'n', 'v' } },
            { '<C-Down>' }, { '<C-Up>' },
        },
    },
    {
        'mbbill/undotree',
        cmd = 'UndotreeToggle',
    },
}
