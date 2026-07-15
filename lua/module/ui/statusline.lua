-- Define statusline highlight groups by linking to TokyoNight semantic hl groups
local function set_statusline_colors()
  local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local bg = normal_hl.bg

  local function fg(name)
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    return hl.fg
  end

  vim.api.nvim_set_hl(0, "SLFilename", { fg = fg("@keyword"), bg = bg, bold = true })
  vim.api.nvim_set_hl(0, "SLLsp", { fg = fg("@function"), bg = bg })
  vim.api.nvim_set_hl(0, "SLError", { fg = fg("DiagnosticError"), bg = bg, bold = true })
  vim.api.nvim_set_hl(0, "SLWarn", { fg = fg("DiagnosticWarn"), bg = bg })
  vim.api.nvim_set_hl(0, "SLHint", { fg = fg("DiagnosticHint"), bg = bg })
  vim.api.nvim_set_hl(0, "SLInfo", { fg = fg("DiagnosticInfo"), bg = bg })
  vim.api.nvim_set_hl(0, "SLCursor", { fg = fg("CursorLineNr"), bg = bg })
  vim.api.nvim_set_hl(0, "SLDefault", { fg = fg("Comment"), bg = bg })
  vim.api.nvim_set_hl(0, "SLRecording", { fg = fg("DiagnosticError"), bg = bg, bold = true })
  -- Session segment: green when saved (matches @string), red/bold when
  -- unsaved (matches DiagnosticError) — set per-state in get_session().
  vim.api.nvim_set_hl(0, "SLSessionSaved", { fg = fg("@string"), bg = bg })
  vim.api.nvim_set_hl(0, "SLSessionUnsaved", { fg = fg("DiagnosticError"), bg = bg, bold = true })
end

set_statusline_colors()
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = set_statusline_colors,
})

-- Get count of LSP servers attached to the current buffer
_G.get_lsp_count = function()
  return #vim.lsp.get_clients({ bufnr = 0 })
end

-- Redraw the statusline whenever LSP clients attach/detach, since
-- there's no more per-second timer driving redraws — the count in
-- get_lsp_count() would otherwise go stale until some other redraw
-- happened to fire.
local lsp_grp = vim.api.nvim_create_augroup("StatuslineLspRefresh", { clear = true })
vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
  group = lsp_grp,
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

-- Get diagnostic counts (only shows items > 0)
_G.get_diagnostics = function()
  local s = vim.diagnostic.severity
  local e = #vim.diagnostic.get(0, { severity = s.ERROR })
  local w = #vim.diagnostic.get(0, { severity = s.WARN })
  local h = #vim.diagnostic.get(0, { severity = s.HINT })
  local i = #vim.diagnostic.get(0, { severity = s.INFO })

  local parts = {}
  if e > 0 then
    table.insert(parts, "%#SLError#E:" .. e)
  end
  if w > 0 then
    table.insert(parts, "%#SLWarn#W:" .. w)
  end
  if h > 0 then
    table.insert(parts, "%#SLHint#H:" .. h)
  end
  if i > 0 then
    table.insert(parts, "%#SLInfo#I:" .. i)
  end

  if #parts == 0 then
    return ""
  end
  return "%#SLDefault#[ " .. table.concat(parts, " ") .. " %#SLDefault#]"
end

-- Current macro recording register
_G.get_macro_recording = function()
  local reg = vim.fn.reg_recording()
  if reg == "" then
    return ""
  end
  return "%#SLRecording#[Recording @" .. reg .. "]"
end

-- Force redraw on macro state changes
local macro_grp = vim.api.nvim_create_augroup("StatuslineMacroRefresh", { clear = true })
vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
  group = macro_grp,
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

-- Session segment: reads the globals set by the separate session
-- manager module (lua/user/session.lua) —
--   _G.PuSessionLoaded  : false, or the loaded session's name (string)
--   _G.PuSessionUnsaved : true/false
-- Only ever renders anything when a session is actually loaded; an
-- unloaded state (PuSessionLoaded == false, or the global not yet
-- defined at all, e.g. session.lua hasn't been required yet) yields "".
_G.get_session = function()
  local name = _G.PuSessionLoaded
  if not name then
    return ""
  end

  local unsaved = _G.PuSessionUnsaved
  local hl = unsaved and "%#SLSessionUnsaved#" or "%#SLSessionSaved#"
  local status = unsaved and "Unsaved" or "Saved"

  return "%#SLDefault#[" .. hl .. "Session: " .. name .. " (" .. status .. ")" .. "%#SLDefault#]"
end

-- Build the full statusline string
_G.build_statusline = function()
  local macro = _G.get_macro_recording()
  local filename = "%#SLDefault#[%#SLFilename#%t%#SLDefault#]"
  local lsp = "[%#SLLsp#Lsp: " .. _G.get_lsp_count() .. "%#SLDefault#]"
  local diag = _G.get_diagnostics()
  local session = _G.get_session()

  local macro_str = macro ~= "" and (macro .. " ") or ""
  local diag_str = diag ~= "" and (" " .. diag) or ""
  local session_str = session ~= "" and (" " .. session) or ""
  local cursor = "%#SLCursor#%l:%c"

  --  LEFT: macro · filename · lsp · diagnostics · session
  -- RIGHT: cursor position
  return macro_str .. filename .. " " .. lsp .. diag_str .. session_str .. "%=" .. cursor
end

vim.o.statusline = "%!v:lua.build_statusline()"
