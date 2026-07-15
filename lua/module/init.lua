require("module.session.config")
require("module.ui.statusline")
require("module.ui.eqalizer")
require("module.autosave.config")
require("module.terminal.config")
require("module.diagPanel.Panel").setup({
  mode = "hsplit",
  height = 8,
})
require("module.bufferline.config").setup()
-- not needed to use run because F1 and F12 works fine
-- and are precise
-- require("module.run.config")
