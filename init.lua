vim.opt.shortmess:append('I')  -- skip intro
vim.opt.shortmess:append('W')  -- skip warnings
vim.notify = function(msg, level)
    if level == vim.log.levels.ERROR then return end
    -- or filter specific messages
    if msg:find('Spawning language server') then return end
    if msg:find('deprecated') then return end
end
-- require("user.sys.profiler") -- Precedence = #1 (for profiling)
require('user.sys.options') -- Precedence = #2
-- =========================================================
-- 1. Safe require helper
-- =========================================================
local function safe_require(module)
    local ok, result = pcall(require, module)
    if not ok then
        vim.notify(
            'Failed to load: ' .. module .. '\n' .. tostring(result),
            vim.log.levels.ERROR,
            { title = 'Module Load Error' }
        )
        return nil
    end
    return result
end

-- =========================================================
-- 2. Auto-discover and load stages in numerical order
-- =========================================================
local function load_stages()
    local stages_path = vim.fn.stdpath('config') .. '/lua/user/stages'
    local files = vim.fn.readdir(stages_path)

    -- Filter for .lua files and sort them numerically
    local lua_files = {}
    for _, file in ipairs(files) do
        if file:match('%.lua$') then
            table.insert(lua_files, file)
        end
    end

    -- Sort numerically by extracting leading numbers
    table.sort(lua_files, function(a, b)
        local num_a = tonumber(a:match('^(%d+)'))
        local num_b = tonumber(b:match('^(%d+)'))
        if num_a and num_b then
            return num_a < num_b
        end
        return a < b -- Fallback to alphabetical
    end)

    -- Load each stage in order
    for _, file in ipairs(lua_files) do
        local module_name = file:gsub('%.lua$', '')
        local stage_module = 'user.stages.' .. module_name
        safe_require(stage_module)
    end
end

load_stages()
-- =========================================================
-- 3. Post-init
-- =========================================================
vim.cmd.colorscheme('tokyonight-moon')
-- This makes the flot sticker a solid vibrant cyan block with dark, bold text inside
vim.api.nvim_set_hl(0, 'FloatTitle', { fg = '#1e1e2e', bg = '#7dcfff', bold = true })

-- 1. Vertical Split Border
-- WinSeparator controls the vertical line between splits
vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#38bdf8', bold = true })


