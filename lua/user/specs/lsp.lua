-- ===========================
-- LSP (load on file open)
-- ===========================
return {
    {
        'neovim/nvim-lspconfig',
--         commit = '5bfcc89',
        event = { 'BufReadPre', 'BufNewFile' },
    },
    {
        'onsails/lspkind-nvim',
--         commit = 'c7274c4',
        lazy = true,
    },
    {
        'SmiteshP/nvim-navic',
--         commit = 'f5eba19',
        lazy = true,
        dependencies = {
            'neovim/nvim-lspconfig',
--             commit = '5bfcc89',
        },
    },
    {
        'folke/trouble.nvim',
--         commit = 'bd67efe',
        opts = {}, -- for default options, refer to the configuration section for custom setup.
        event = 'BufReadPre',
        keys = {
            {
                '<leader>tt',
                '<cmd>Trouble diagnostics toggle<cr>',
                desc = 'Trouble Toggle',
            },
        },
    },
    {
        'saecki/crates.nvim',
--         commit = 'afcd1cc',
        event = 'Bufread Cargo.toml',
        tag = 'stable',
        config = function()
            require('crates').setup()
        end,
    },
}
