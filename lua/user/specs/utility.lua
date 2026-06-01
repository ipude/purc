-- ===========================
-- Utility Features
-- ===========================
return {
    {
        'echasnovski/mini.clue',
        event = 'VeryLazy',
        config = function()
            local clue = require('mini.clue')

            clue.setup({
                window = {
                    delay = 200,
                    config = {
                        border = vim.g.float_border_style,
                    },
                },

                triggers = {
                    { mode = 'n', keys = '<Leader>' },
                    { mode = 'x', keys = '<Leader>' },
                    { mode = 'n', keys = 'g' },
                    { mode = 'x', keys = 'g' },
                    { mode = 'n', keys = "'" },
                    { mode = 'n', keys = '`' },
                    { mode = 'n', keys = '"' },
                    { mode = 'n', keys = '<C-w>' },
                    { mode = 'n', keys = 'z' },
                    { mode = 'x', keys = 'z' },
                    clue.gen_clues.g(),
                    clue.gen_clues.marks(),
                    clue.gen_clues.registers(),
                    clue.gen_clues.windows(),
                    clue.gen_clues.z(),
                },

                clues = {
                    { mode = 'n', keys = '<leader>b', desc = ' Buffers' },
                    { mode = 'n', keys = '<leader>l', desc = ' Lazy / LSP' },
                    { mode = 'n', keys = '<leader>ll', desc = ' Lazy' },
                    { mode = 'n', keys = '<leader>ls', desc = ' LSP Server' },
                    { mode = 'n', keys = '<leader>G', desc = ' Git' },
                    { mode = 'n', keys = '<leader>h', desc = ' History' },
                    { mode = 'n', keys = '<leader>r', desc = '󰛔 Reload / Restart' },
                    { mode = 'n', keys = '<leader>q', desc = ' Quit' },
                    { mode = 'n', keys = '<leader>qf', desc = ' Force Quit' },
                    { mode = 'n', keys = '<leader>u', desc = ' UI Toggles' },
                    { mode = 'n', keys = '<leader>w', desc = ' Write / Save' },
                    { mode = 'n', keys = '<leader>wf', desc = ' Force Write' },
                    { mode = 'n', keys = '<leader>y', desc = ' Yank' },
                    { mode = 'v', keys = '<leader>r', desc = '󰛔 Replace' },
                    { mode = 'x', keys = '<leader>r', desc = '󰛔 Replace' },
                }
            })
        end,
    },
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
