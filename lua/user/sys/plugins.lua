-- Enable Lua module caching
vim.loader.enable()

-- =====================
-- (1) Bootstrap lazy.nvim
-- =====================
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
-- =====================
-- Plugins (lazy.nvim)
-- =====================
require('lazy').setup({
    spec = {
        { import = 'user.specs.core' },
        { import = 'user.specs.snippets' },
        { import = 'user.specs.completion' },
        { import = 'user.specs.lsp' },
        { import = 'user.specs.formatting' },
        { import = 'user.specs.ui' },
        { import = 'user.specs.treesitter' },
        { import = 'user.specs.explorer' },
        { import = 'user.specs.editor' },
        { import = 'user.specs.utility' },
        { import = 'user.specs.session' },
        { import = 'user.specs.mini' },
        { import = 'user.specs.colorschemes' },
        { import = 'user.specs.fold' },
    },

    -- ============================
    -- Configuration
    -- ============================
    concurrency = 5,

    git = {
        timeout = 300,
        url_format = 'https://github.com/%s.git',
    },

    install = {
        missing = false,
    },

    rocks = {
        enabled = false,
        hererocks = false,
    },

    checker = {
        enabled = false,
        notify = false,
        frequency = 3600,
    },

    change_detection = {
        enabled = false,
        notify = false,
    },

    performance = {
        cache = {
            enabled = true,
        },
        reset_packpath = true,
        rtp = {
            reset = true,
            paths = {},
            disabled_plugins = {
                'gzip',
                'matchit',
                'matchparen',
                'netrwPlugin',
                'tarPlugin',
                'tohtml',
                'tutor',
                'zipPlugin',
            },
        },
    },

    defaults = {
        lazy = true,
        version = false,
    },

    ui = {
        size = { width = 0.88, height = 0.9 },
        wrap = true,
        title = '   Lazy Plugin Manager ',
        backdrop = 70,
        icons = {
            cmd        = '󰘳 ',
            config     = '󰒓 ',
            event      = '󰚌 ',
            ft         = '󰈙 ',
            init       = '󰒓 ',
            import     = '󰋺 ',
            keys       = '󰌌 ',
            lazy       = '󰒲 ',
            loaded     = '󰄬 ',
            not_loaded = '󰄱 ',
            plugin     = '󰂖 ',
            runtime    = '󰆦 ',
            source     = '󰉋 ',
            start      = '󰐊 ',
            task       = '󰆕 ',
            list       = { '󰬪', '󰬜', '󰬐', '󰬅' },
        }
    },
})
