return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false, -- plugin explicitly says no lazy-loading
        build = ':TSUpdate',

        config = function()
            require('nvim-treesitter').setup {
                install_dir = vim.fn.stdpath('data') .. '/site'
            }

            -- install() is async; :wait() only needed for bootstrapping scripts
            -- safe to leave as-is if you want blocking install on first launch
            require('nvim-treesitter').install({
                'lua', 'javascript', 'zig', 'go', 'python' -- 'golang' → 'go'
            }):wait(300000)

            vim.api.nvim_create_autocmd('FileType', {
                pattern = { 'lua', 'javascript', 'zig', 'go', 'python' },
                callback = function()
                    vim.treesitter.start()
                    vim.wo[0][0].foldexpr   = 'v:lua.vim.treesitter.foldexpr()'
                    vim.wo[0][0].foldmethod = 'expr'
                    vim.wo[0][0].foldlevel  = 99 -- open all folds by default
                    vim.bo.indentexpr       = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end
    },
}

