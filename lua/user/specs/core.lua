-- ===========================
-- Core Dependencies (lazy loaded)
-- ===========================
return {
    {
        'nvim-lua/plenary.nvim',
        commit = '74b06c6',
    },
    {
        'MunifTanjim/nui.nvim',
        commit = 'de74099',
        lazy = true
    },
    {
        'nvim-tree/nvim-web-devicons',
        commit = '4fc505a',
        lazy = true
    },
    {
        'nvim-neotest/nvim-nio',
        commit = '21f5324',
        lazy = true
    },
    {
        'ojroques/nvim-osc52',
        config = function()
            require('osc52').setup({ max_length = 0 })

            vim.keymap.set('n', '<leader>ym', require('osc52').copy_operator,
                { expr = true, desc = 'Copy motion to system' })
            vim.keymap.set('v', '<leader>yt', require('osc52').copy_visual,
                { desc = 'Copy visual selection to system clipboard' })

            -- Manually push yank register to system clipboard
            vim.keymap.set('n', '<leader>yc', function()
                require('osc52').copy_register('"')
            end, { desc = 'Copy yank register to system clipboard' })
        end,
    },
}
