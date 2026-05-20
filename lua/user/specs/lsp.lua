-- ===========================
-- LSP (load on file open)
-- ===========================
return {
    {
        'onsails/lspkind-nvim',
        lazy = true,
    },
    -- {
    --     'SmiteshP/nvim-navic',
    --     lazy = true,
    --     dependencies = {
    --         'neovim/nvim-lspconfig',
    --     },
    -- },
    {
        'folke/trouble.nvim',
        opts = {},
        keys = {
            { '<leader>dt', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Trouble Toggle' },
        },
    },
    {
        'saecki/crates.nvim',
        event = 'Bufread Cargo.toml',
        tag = 'stable',
        config = function()
            require('crates').setup()
        end,
    },
}
