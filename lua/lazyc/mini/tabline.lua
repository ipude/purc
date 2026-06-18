-- Minimal bufferline for Neovim 0.12+
--
-- Shows:
--   1. All listed buffers
--   2. Only the buffer's filename (no path)
--   3. "current tab:total tabs" right-aligned
--
-- Usage: source this file from your init.lua, e.g.
--   require("bufferline")  -- if placed at lua/bufferline.lua
-- or just paste the contents into init.lua directly.

-- current buf/tab (bold, resolved from PmenuSel since `link` drops extra attrs),
-- unsaved changes marker, inactive buf
vim.api.nvim_set_hl(0, "TabLineSel", {link = "Cursor" ,bold = true })
vim.api.nvim_set_hl(0, "TabLineModified", { link = "DiagnosticWarn", bold = true })
vim.api.nvim_set_hl(0, "TabLine", { link = "Comment" })
vim.api.nvim_set_hl(0, "TabLineCount", { link = "Cursor", bold = true })

local function tab_label(buf, is_current)
  local name = vim.api.nvim_buf_get_name(buf)
  name = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[No Name]"

  local hl
  if is_current then
    hl = "%#TabLineSel#"
  elseif vim.bo[buf].modified then
    hl = "%#TabLineModified#"
  else
    hl = "%#TabLine#"
  end

  return hl .. " " .. name .. " "
end

function _G.minimal_bufferline()
  local current = vim.api.nvim_get_current_buf()
  local parts = {}

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted then
      table.insert(parts, tab_label(buf, buf == current))
    end
  end

  -- fill remaining space, then right-align tab count
  table.insert(parts, "%#TabLineFill#%=")
  table.insert(
    parts,
    string.format("%%#TabLineCount# %d:%d ", vim.fn.tabpagenr(), vim.fn.tabpagenr("$"))
  )

  return table.concat(parts)
end

vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.minimal_bufferline()"

