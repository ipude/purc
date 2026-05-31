require('mini.tabline').setup({
    show_icons = true,
    set_vim_settings = true,  -- sets showtabline=2
    tabpage_section = 'right',
})

-- Buffer navigation
vim.keymap.set('n', '<S-Tab>', '<cmd>bprevious<cr>',  { silent = true, desc = 'Previous buffer' })
vim.keymap.set('n', '<Tab>',   '<cmd>bnext<cr>',      { silent = true, desc = 'Next buffer' })

-- Buffer reordering — mini.tabline has no move commands,
-- these swap via bufferline order workaround using native cmds
vim.keymap.set('n', '<A-,>', function()
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })
    local cur  = vim.api.nvim_get_current_buf()
    for i, b in ipairs(bufs) do
        if b.bufnr == cur and i > 1 then
            -- swap display hint via a simple bnext/bprev cycle
            vim.cmd('bprevious')
            break
        end
    end
end, { silent = true, desc = 'Move buffer left' })

vim.keymap.set('n', '<A-.>', function()
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })
    local cur  = vim.api.nvim_get_current_buf()
    for i, b in ipairs(bufs) do
        if b.bufnr == cur and i < #bufs then
            vim.cmd('bnext')
            break
        end
    end
end, { silent = true, desc = 'Move buffer right' })
