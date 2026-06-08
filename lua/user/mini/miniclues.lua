local miniclue = require('mini.clue')

-- ============================================
-- SETUP
-- ============================================
miniclue.setup({
    -- Delay before the clue window appears (ms)
    window = {
        delay = 50,
        config = {
            border = 'rounded',
            -- winblend = 0 is the default, omit if not needed
        },
    },

    -- Triggers: which key presses activate the clue popup
    triggers = {
        -- Leader key (normal, visual, operator-pending)
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },
        { mode = 'o', keys = '<Leader>' },

        -- Built-in useful triggers
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },
        { mode = 'n', keys = '[' },
        { mode = 'n', keys = ']' },
        { mode = 'n', keys = '<C-w>' },
        { mode = 'n', keys = 'z' },
        { mode = 'x', keys = 'z' },
        { mode = 'i', keys = '<C-x>' },
        { mode = 'n', keys = "'" },
        { mode = 'n', keys = '`' },
        { mode = 'n', keys = '"' },
        { mode = 'i', keys = '<C-r>' },
        { mode = 'c', keys = '<C-r>' },
        { mode = 'x', keys = '[' },
        { mode = 'x', keys = ']' },
    },

    clues = {
        -- Built-in clue generators
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),
        miniclue.gen_clues.square_brackets(),

        -- ============================================
        -- TOP-LEVEL GROUP DEFINITIONS
        -- ============================================
        { mode = 'n', keys = '<Leader>b', desc = '󰓩 Buffers' },
        { mode = 'n', keys = '<Leader>c', desc = '󱘗 Filetype Commands' },
        { mode = 'n', keys = '<Leader>d', desc = '󰃤 Diagnostics' },
        { mode = 'n', keys = '<Leader>e', desc = '󰍉 Fzf Flexible' },
        { mode = 'n', keys = '<Leader>f', desc = '󰍉 Find Files' },
        { mode = 'n', keys = '<Leader>g', desc = '󰍉 Grep' },
        { mode = 'n', keys = '<Leader>G', desc = '󰊢 GIT' },
        { mode = 'n', keys = '<Leader>h', desc = '󰋚 History' },
        { mode = 'n', keys = '<Leader>l', desc = '󰒲 Lazy / LSP' },
        { mode = 'n', keys = '<Leader>o', desc = '󰇥 Yazi' },
        { mode = 'n', keys = '<Leader>p', desc = '󰅇 Paste' },
        { mode = 'n', keys = '<Leader>q', desc = '󰗼 Quit' },
        { mode = 'n', keys = '<Leader>r', desc = '󰑓 Reload' },
        { mode = 'n', keys = '<Leader>s', desc = '󰆓 Sessions' },
        { mode = 'n', keys = '<Leader>t', desc = '󰆍 Task' },
        { mode = 'n', keys = '<Leader>u', desc = '󰔡 Toggles' },
        { mode = 'n', keys = '<Leader>w', desc = '󰆓 Advanced Save' },
        { mode = 'n', keys = '<Leader>y', desc = '󰅎 Yank' },
        { mode = 'n', keys = '<Leader>z', desc = '󱐋 Code Runner' },

        -- ============================================
        -- SUB-GROUP DEFINITIONS
        -- ============================================
        { mode = 'n', keys = '<Leader>fi', desc = '󰍉 Find Files ..' },
        { mode = 'n', keys = '<Leader>gi', desc = '󰊢 Grep in ..' },
        { mode = 'n', keys = '<Leader>ll', desc = '󰒲 Lazy' },
        { mode = 'n', keys = '<Leader>lo', desc = '󰏗 Plug Load' },
        { mode = 'n', keys = '<Leader>ls', desc = '󰒍 LSP Server' },
        { mode = 'n', keys = '<Leader>qf', desc = '󰗼 Force Quit' },
        { mode = 'n', keys = '<Leader>wf', desc = '󰆓 Force Save' },

        -- Visual mode groups
        { mode = 'x', keys = '<Leader>r', desc = '󰛔 Replace' },
        { mode = 'v', keys = '<Leader>r', desc = '󰛔 Replace' },
    },
})
-- ============================================
-- ENABLE MINI.CLUE IN SPECIAL BUFFERS
-- ============================================
local special_ft = { "oil", "toggleterm", "neo-tree", "lazy", "mason" }
local special_bt = { "terminal", "acwrite", "nofile", "prompt" }

local function maybe_enable(buf)
    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype
    local ft_match = vim.tbl_contains(special_ft, ft)
    local bt_match = vim.tbl_contains(special_bt, bt)

    if ft_match or bt_match then
        vim.schedule(function()
            pcall(require("mini.clue").enable_buf_triggers, buf)
        end)
    end
end

vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "TermOpen" }, {
    callback = function(ev)
        maybe_enable(ev.buf)
    end,
})

-- ============================================
-- BUFFERS
-- ============================================
vim.keymap.set('n', '<Leader>bs', '<Cmd>w<CR>', { desc = 'Buffer Save [Only for Oil etc buffers]' })
vim.keymap.set('n', '<Leader>bc', '<Cmd>%d<CR>', { desc = 'Buffer Remove data [!RISKY!]' })
vim.keymap.set('n', '<Leader>bd', '<Cmd>bdelete<CR>', { desc = 'Buffer Close [SAFE]' })
vim.keymap.set('n', '<Leader>bb', function() require('fzf-lua').buffers() end, { desc = 'Pick buffer' })

-- ============================================
-- GIT
-- ============================================
vim.keymap.set('n', '<Leader>lg', '<Cmd>LazyGit<CR>', { desc = 'LazyGit' })
vim.keymap.set('n', '<Leader>Gl', '<Cmd>LazyGit<CR>', { desc = 'LazyGit' })

-- ============================================
-- NOTIFICATIONS
-- ============================================
vim.keymap.set('n', '<Leader>hn', '<Cmd>lua MiniNotify.show_history()<CR>', { desc = 'Notification History' })

-- ============================================
-- RELOAD
-- ============================================
vim.keymap.set('n', '<Leader>rr', '<Cmd>mksession! Session.vim | restart source Session.vim<CR>',
    { desc = 'Restart (Save & Restore Session)' })
vim.keymap.set('n', '<Leader>rs', '<Cmd>restart<CR>', { desc = 'Restart Safely (Fails if Unsaved)' })
vim.keymap.set('n', '<Leader>rf', '<Cmd>restart +qall!<CR>', { desc = 'Restart & Discard Unsaved Changes' })

-- ============================================
-- QUIT
-- ============================================
vim.keymap.set('n', '<Leader>qq', '<Cmd>q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<Leader>qfq', '<Cmd>q!<CR>', { desc = 'Force Quit' })
vim.keymap.set('n', '<Leader>qfa', '<Cmd>qa<CR>', { desc = 'Quit All' })
vim.keymap.set('n', '<Leader>qfw', '<Cmd>qa!<CR>', { desc = 'Force Quit All' })

-- ============================================
-- TOGGLES
-- ============================================
vim.keymap.set('n', '<Leader>un', '<Cmd>set number!<CR>', { desc = 'Line Numbers' })
vim.keymap.set('n', '<Leader>ur', '<Cmd>set relativenumber!<CR>', { desc = 'Relative Numbers' })
vim.keymap.set('n', '<Leader>uw', '<Cmd>set wrap!<CR>', { desc = 'Word Wrap' })
vim.keymap.set('n', '<Leader>uc', '<Cmd>set cursorline!<CR>', { desc = 'Cursor Line' })
vim.keymap.set('n', '<Leader>uh', '<Cmd>set hlsearch!<CR>', { desc = 'Highlight Search' })

-- ============================================
-- SAVE
-- ============================================
vim.keymap.set('n', '<Leader>ws', '<Cmd>wall<CR>', { desc = 'Save All' })
vim.keymap.set('n', '<Leader>wq', '<Cmd>wq<CR>', { desc = 'Save & Quit' })
vim.keymap.set('n', '<Leader>wfs', '<Cmd>w!<CR>', { desc = 'Force Save' })
vim.keymap.set('n', '<Leader>wfS', '<Cmd>wall!<CR>', { desc = 'Force Save All' })
vim.keymap.set('n', '<Leader>wfa', '<Cmd>wqall!<CR>', { desc = 'Force Save & Quit All' })

-- ============================================
-- YANK
-- ============================================
vim.keymap.set('n', '<Leader>ya', '<Cmd>%y+<CR>', { desc = 'Yank All' })
vim.keymap.set('n', '<Leader>yp', "<Cmd>let @+ = expand('%:p')<CR>", { desc = 'Yank File Path' })
vim.keymap.set('n', '<Leader>yf', "<Cmd>let @+ = expand('%:t')<CR>", { desc = 'Yank File Name' })

-- ============================================
-- LAZY
-- ============================================
vim.keymap.set('n', '<Leader>llp', '<Cmd>Lazy profile<CR>', { desc = 'Profile' })
vim.keymap.set('n', '<Leader>llu', '<Cmd>Lazy update<CR>', { desc = 'Update' })
vim.keymap.set('n', '<Leader>lls', '<Cmd>Lazy sync<CR>', { desc = 'Sync' })

-- ============================================
-- LSP SERVER
-- ============================================
vim.keymap.set('n', '<Leader>lsi', '<Cmd>LspInfo<CR>', { desc = 'Info' })
vim.keymap.set('n', '<Leader>lsl', '<Cmd>LspLog<CR>', { desc = 'Log' })
vim.keymap.set('n', '<Leader>lsr', '<Cmd>LspRestart<CR>', { desc = 'Restart' })

-- ============================================
-- VISUAL MODE
-- ============================================
vim.keymap.set({ 'v', 'x' }, '<Leader>y', '"+y', { desc = 'Yank to Clipboard' })

-- ============================================
-- KEYMAP CONFLICT CHECKER  (run :CheckKeymaps)
-- ============================================
local function check_leader_conflicts()
    local seen = {}
    local conflicts = {}

    for _, map in ipairs(vim.api.nvim_get_keymap('n')) do
        if map.lhs:match('^<leader>') then
            if seen[map.lhs] then
                table.insert(conflicts, string.format(
                    '  %-20s  %s  ←→  %s', map.lhs, seen[map.lhs], map.rhs or '?'
                ))
            else
                seen[map.lhs] = map.rhs or '?'
            end
        end
    end

    if #conflicts > 0 then
        vim.notify(
            '󰀪 Leader conflicts found:\n' .. table.concat(conflicts, '\n'),
            vim.log.levels.WARN,
            { title = 'Keymap Conflicts' }
        )
    else
        vim.notify('󰸞 No leader conflicts found', vim.log.levels.INFO, { title = 'Keymaps' })
    end
end

vim.api.nvim_create_user_command('CheckKeymaps', check_leader_conflicts, {
    desc = 'Check for leader keymap conflicts',
})
