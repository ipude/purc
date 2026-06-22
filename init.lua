-- vim thing
-- must load first
vim.loader.enable()
require("vim._core.ui2").enable()
require("startup.theme")

-- your core
require("sys")
require("map")
require("ui")

-- main plugin file
-- must load
vim.defer_fn(function() 
  require("plugin")
end, 0)

-- your local modules
-- very small in size
require("module")

-- VimEnter Stuff
-- Load at last
require("server")
require("lazyc.mini.tabline_motion")

-- Lazy parsers
-- priority = last
require("treesitters.lazy")

-- lua/lazy/
require("lazyc.explore.oil")
require("lazyc.explore.fzf")
require("lazyc.mini.miniclues")
require("lazyc.mini.icons")
require("lazyc.mini.indent")
