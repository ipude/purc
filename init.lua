vim.loader.enable()
require("vim._core.ui2").enable()
require("sys")
require("map")
require("ui")
require("plugin")
require("module")
require("server")

local function start_buffer(buf)
  local ok = pcall(vim.treesitter.start, buf)
  if not ok then
    return -- no parser installed yet (e.g. :TSInstall hasn't been run) — skip quietly
  end
  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo[win].foldmethod = "expr"
    vim.wo[win].foldlevel = 99
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.defer_fn(function()
      -- phase 1: buffers already open before this fired
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          start_buffer(buf)
        end
      end

      -- phase 2: hand off to FileType for everything opened afterward
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          start_buffer(args.buf)
        end,
      })
    end, 50)
  end,
})
