-- user/config/ide/file/fzf.lua

-- Highlights are cheap, keep these at top level
vim.api.nvim_set_hl(0, 'FzfLuaNormal', { link = 'Normal' })
vim.api.nvim_set_hl(0, 'FzfLuaBorder', { link = 'FloatBorder' })
vim.api.nvim_set_hl(0, 'FzfLuaTitle', { link = 'Title' })
vim.api.nvim_set_hl(0, 'FzfLuaPreviewNormal', { link = 'Normal' })
vim.api.nvim_set_hl(0, 'FzfLuaCursorLine', { link = 'Visual' })
vim.api.nvim_set_hl(0, 'FzfLuaCursor', { link = 'IncSearch' })

-- Setup runs on first keypress, not at startup
local setup_done = false
local function fzf()
    if not setup_done then
        setup_done = true
        require('fzf-lua').setup({
            winopts = {
                height  = 0.85,
                width   = 0.80,
                row     = 0.35,
                col     = 0.50,
                border  = 'rounded',
                preview = {
                    border = 'rounded',
                    wrap = 'nowrap',
                    hidden = 'nohidden',
                    vertical = 'down:45%',
                    horizontal = 'right:60%',
                    layout = 'flex',
                    flip_columns = 120,
                },
            },
            fzf_colors = {
                ['fg'] = { 'fg', 'Normal' },
                ['bg'] = { 'bg', 'Normal' },
                ['fg+'] = { 'fg', 'Normal' },
                ['bg+'] = { 'bg', 'Visual' },
                ['hl'] = { 'fg', 'Identifier' },
                ['hl+'] = { 'fg', 'Statement' },
                ['prompt'] = { 'fg', 'Keyword' },
                ['pointer'] = { 'fg', 'Type' },
                ['marker'] = { 'fg', 'Type' },
                ['header'] = { 'fg', 'Title' },
                ['info'] = { 'fg', 'Special' },
            },
            files = {
                prompt = ' ',
                multiprocess = true,
                git_icons = true,
                file_icons = true,
                color_icons = true,
                fd_opts = '--color=never --type f --hidden --follow --exclude .git',
            },
            grep = {
                prompt = ' ',
                input_prompt = 'Grep  ',
                multiprocess = true,
                git_icons = true,
                file_icons = true,
                color_icons = true,
                rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case -g '!.git'",
            },
        })
    end
    return require('fzf-lua')
end

-- Termux detection (computed once, not per keypress)
-- ============================
-- Functions
-- ============================
local _home, _root
local function sys_home()
    if _home then return _home end
    _home = vim.env.TERMUX_VERSION and '/data/data/com.termux/files/home' or vim.env.HOME or vim.fn.getcwd()
    return _home
end
local function sys_root()
    if _root then return _root end
    _root = vim.env.TERMUX_VERSION and '/data/data/com.termux/files' or '/'
    return _root
end

-- ============================
-- find file -- keymaps
-- ============================
local k = vim.keymap.set
k('n', '<leader>fz', function()
    fzf().setup_called = true; vim.cmd('FzfLua')
end, { desc = 'FzfLua' })

k('n', '<leader>fd', function() fzf().files() end, { desc = 'Find files CWD' })

k('n', '<leader>fo', function() fzf().oldfiles() end, { desc = 'Recent files' })

k('n', '<leader>fc',
    function() fzf().files({ cwd = vim.fn.expand('$MYVIMRC'):match('(.*/)'), prompt = '< Neovim Config > ' }) end,
    { desc = 'Find config files' })

k('n', '<leader>fs',
    function() fzf().files({ cwd = vim.fn.stdpath('config') .. '/lua/user/stages', prompt = '< User Stages > ' }) end,
    { desc = 'Find stage files' })


k('n', '<leader>fih', function() fzf().files({ cwd = sys_home() }) end, { desc = 'Find Files in HOME' })

k('n', '<leader>fir', function() fzf().files({ cwd = sys_root() }) end, { desc = 'Find Files in ROOT' })


-- ============================
-- diagnostics -- keymaps
-- ============================

k('n', '<leader>dw', function() fzf().diagnostics_workspace() end, { desc = 'Workspace diagnostics' })

-- ============================
-- grep dir -- map
-- ============================
k('n', '<leader>gd', function() fzf().live_grep({prompt = "GrepCwd: "}) end, { desc = 'Live grep CWD' })

k('n', '<leader>gc', function() fzf().live_grep({ cwd = vim.fn.stdpath('config'), prompt = 'GrepConfig: ' }) end,
    { desc = 'Grep config' })

k('n', '<leader>gs', function() fzf().live_grep({ cwd = vim.fn.stdpath('config') .. '/lua/user/stages/', prompt = 'GrepStages: ' }) end,
    { desc = 'Grep config' })

-- ============================
-- grep in -- map
-- ============================

k('n', '<leader>gih', function() fzf().live_grep({ cwd = sys_home(), prompt = "GrepHome/" }) end, { desc = 'Grep home' })
k('n', '<leader>gir', function() fzf().live_grep({ cwd = sys_root(), prompt = "GrepRoot/" }) end, { desc = 'Grep root' })

k('n', '<leader>Gc', function() fzf().git_commits() end, { desc = 'Git commits' })

k('n', '<leader>Gs', function() fzf().git_status() end, { desc = 'Git status' })







-- In your keymaps file

local function fzf_in_custom_dir(mode)
  mode = mode or "files"

  -- Floating input prompt
  vim.ui.input({
    prompt = " Dir: ",
    default = vim.fn.getcwd(),
    completion = "dir",   -- <Tab> completes directory names
  }, function(input)
    if not input or input == "" then return end

    -- Expand ~, $ENV_VAR, shell globs
    local path = vim.fn.expand(input)

    -- Also resolve env vars the expand() may have missed
    path = path:gsub("%$(%w+)", function(var)
      return os.getenv(var) or ("$" .. var)
    end)

    if vim.fn.isdirectory(path) == 0 then
      vim.notify("Not a directory: " .. path, vim.log.levels.ERROR)
      return
    end

    if mode == "files" then
      require("fzf-lua").files({ cwd = path })
    elseif mode == "grep" then
      require("fzf-lua").live_grep({ cwd = path })
    elseif mode == "explorer" then
      require("fzf-lua").file_browser({ cwd = path })
    end
  end)
end

-- Keymaps
vim.keymap.set("n", "<leader>ef", function() fzf_in_custom_dir("files") end,
  { desc = "FZF files in typed dir", noremap = true, silent = true })

vim.keymap.set("n", "<leader>eg", function() fzf_in_custom_dir("grep") end,
  { desc = "FZF grep in typed dir", noremap = true, silent = true })
