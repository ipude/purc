-- Core system (truly needed at startup)
-- =======================================================================================
require('user.sys.env')        -- env vars, must be first
require('user.sys.plugins')    -- plugin manager, must be early
require('user.sys.lazy_map')    -- plugin manager, must be early
-- =======================================================================================

-- =======================================================================================
-- NOTE: Run this to time plugin spec loading else use plugins.lua and comment this.
-- look at --> :e ~/.cache/nvim/spec_times.log just after loading without exiting
-- require('user.sys._time_plugins')
-- =======================================================================================


-- =======================================================================================
require('user.sys.paste_from_sys') -- clipboard, not needed until first paste
-- Defer everything else
vim.schedule(function()
    require('user.mini.mini_notify')   -- notifications, not needed until first notify
  require('user.sys.last_pos')       -- last position, fires on BufReadPost anyway
  -- require('user.sys.options')       -- last position, fires on BufReadPost anyway
end)
-- =======================================================================================
