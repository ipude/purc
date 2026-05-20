return {
    {
        'willothy/nvim-cokeline',
    },
    {
        'stevearc/dressing.nvim',
        lazy = true,
        opts = {
            input = {
                enabled        = true,
                default_prompt = 'Input',
                trim_prompt    = true,
                title_pos      = 'left',
                start_mode     = 'insert',
                border         = 'rounded',
                relative       = 'cursor',
                prefer_width   = 40,
                max_width      = { 140, 0.9 },
                min_width      = { 20, 0.2 },
                win_options    = {
                    wrap          = true,
                    list          = true,
                    listchars     = 'precedes:…,extends:…',
                    sidescrolloff = 0,
                },
                mappings       = {
                    n = { ['<Esc>'] = 'Close', ['<CR>'] = 'Confirm' },
                    i = { ['<C-c>'] = 'Close', ['<CR>'] = 'Confirm', ['<Up>'] = 'HistoryPrev', ['<Down>'] = 'HistoryNext' },
                },
            },
            select = {
                enabled     = true,
                backend     = { 'fzf_lua', 'fzf', 'builtin' }, -- telescope removed
                trim_prompt = true,
                fzf_lua     = {},
                builtin     = {
                    show_numbers = true,
                    border       = 'rounded',
                    relative     = 'editor',
                    win_options  = {
                        cursorline    = true,
                        cursorlineopt = 'both',
                        winhighlight  = 'MatchParen:',
                        statuscolumn  = ' ',
                    },
                    max_width    = { 140, 0.8 },
                    min_width    = { 40, 0.2 },
                    max_height   = 0.9,
                    min_height   = { 10, 0.2 },
                    mappings     = { ['<Esc>'] = 'Close', ['<C-c>'] = 'Close', ['<CR>'] = 'Confirm' },
                },
            },
        },

    },
    {
        'rcarriga/nvim-notify',
        --         commit = 'a3020c2',
        init = function()
            local original_notify = vim.notify
            vim.notify = function(...)
                vim.notify = original_notify
                require('lazy').load({ plugins = { 'nvim-notify' } })
                vim.notify(...)
            end
        end,
    },
    {
        'beauwilliams/focus.nvim',
        --         commit = '4135f97',
        cmd = { 'FocusSplitNicely', 'FocusSplitCycle', 'FocusToggle' },
    },

    -- in user/specs/ui.lua or wherever your UI plugins live
    {
        'lukas-reineke/indent-blankline.nvim',
        main   = 'ibl',
        lazy   = true,
        config = function()
            require('ibl').setup({
                indent = {
                    char = '│', -- or '▏' for thinner, '┊' for dotted
                    tab_char = '│',
                    highlight = { 'IblIndent' },
                    smart_indent_cap = true,
                },

                whitespace = {
                    remove_blankline_trail = true,
                },

                scope = {
                    enabled = false, -- Let mini.indentscope handle this
                },

                exclude = {
                    filetypes = {
                        'help', 'dashboard', 'neo-tree', 'Trouble', 'trouble',
                        'lazy', 'mason', 'notify', 'toggleterm', 'lazyterm',
                        'packer', 'checkhealth', 'man', 'gitcommit',
                        'TelescopePrompt', 'TelescopeResults', 'lspinfo',
                        'alpha', 'starter', '',
                    },
                    buftypes = {
                        'terminal', 'nofile', 'quickfix', 'prompt',
                    },
                },
            })
        end
    },

    {
        'folke/noice.nvim',
        event = 'VeryLazy',
        dependencies = {
            'MunifTanjim/nui.nvim',
        },
        init = function()
            -- Prevent noice from ever overriding vim.notify
            vim.g.noice_notify_enabled = false
        end,
        opts = {
            messages = {
                enabled = false, -- hands ALL cmdline messages back to neovim default / mini.notify
            },
            notify = { enabled = false },
            lsp = {
                progress = { enabled = false },
                hover = { enabled = true },
                message = { enabled = false },
                override = {
                    ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                    ['vim.lsp.util.stylize_markdown'] = true,
                    ['cmp.entry.get_documentation'] = true,
                },
            },
            presets = {
                bottom_search = false,
                command_palette = true,
                long_message_to_split = true,
                inc_rename = false,
            },
            stages = "static",
        },
    },

    vim.keymap.set("n", '<leader>ri', '<cmd>Lazy load indent-blankline.nvim<cr>'),
    vim.keymap.set("n", '<leader>rd', '<cmd>Lazy load dressing.nvim<cr>'),
}
