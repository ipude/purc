-- ═══════════════════════════════════════════════════════════════════════
-- TokyoNight Moon statusline — "pure" style
-- Flat, minimal, high-contrast: colored text segments on a single dark
-- background, separated by a thin muted divider. No powerline blocks/
-- arrows — this reads cleanly against any background/colorscheme.
-- ═══════════════════════════════════════════════════════════════════════

-- Explicit TokyoNight "Moon" palette — hardcoded so segment colors stay
-- distinct and readable regardless of what the active colorscheme links
-- resolve to.
local moon = {
  bg = "#1e2030", -- slightly darker than editor bg: a subtle, flat bar
  fg = "#c8d3f5",
  fg_dark = "#828bb8",
  comment = "#3b4261", -- dim divider color
  red = "#ff757f",
  orange = "#ff966c",
  yellow = "#ffc777",
  green = "#c3e88d",
  teal = "#4fd6be",
  cyan = "#86e1fc",
  blue = "#82aaff",
  blue1 = "#65bcff",
  magenta = "#c099ff",
  purple = "#fca7ea",
}

-- Nerd font glyphs
local icons = {
  lsp = "Lsp 󱁤",               -- Code braces / LSP
  error = "󰅚",             -- Error circle
  warn = "󰀪",              -- Warning triangle
  hint = "󰌵",              -- Lightbulb
  info = "󰋼",              -- Information
  macro = "󰘳",             -- Keyboard/macro
  session_saved = " 󰄬",     -- Check all
  session_unsaved = " 󰆓",   -- Save edit
  cursor = "󰆾",            -- Cursor
  divider = "",            -- Thin divider
}

-- Per-mode display: label + accent color + icon. Keys are vim.fn.mode().
local mode_map = {
  ["n"] = { "NORMAL", moon.blue, "" },
  ["no"] = { "O-PENDING", moon.blue, "" },
  ["nov"] = { "O-PENDING", moon.blue, "" },
  ["noV"] = { "O-PENDING", moon.blue, "" },
  ["no\22"] = { "O-PENDING", moon.blue, "" },
  ["niI"] = { "NORMAL", moon.blue, "" },
  ["niR"] = { "NORMAL", moon.blue, "" },
  ["niV"] = { "NORMAL", moon.blue, "" },
  ["v"] = { "VISUAL", moon.magenta, "" },
  ["vs"] = { "VISUAL", moon.magenta, "" },
  ["V"] = { "V-LINE", moon.magenta, "" },
  ["Vs"] = { "V-LINE", moon.magenta, "" },
  ["\22"] = { "V-BLOCK", moon.purple, "" },
  ["\22s"] = { "V-BLOCK", moon.purple, "" },
  ["s"] = { "SELECT", moon.orange, "" },
  ["S"] = { "S-LINE", moon.orange, "" },
  ["\19"] = { "S-BLOCK", moon.orange, "" },
  ["i"] = { "INSERT", moon.green, "" },
  ["ic"] = { "INSERT", moon.green, "" },
  ["ix"] = { "INSERT", moon.green, "" },
  ["R"] = { "REPLACE", moon.red, "" },
  ["Rc"] = { "REPLACE", moon.red, "" },
  ["Rx"] = { "REPLACE", moon.red, "" },
  ["Rv"] = { "V-REPLACE", moon.red, "" },
  ["Rvc"] = { "V-REPLACE", moon.red, "" },
  ["Rvx"] = { "V-REPLACE", moon.red, "" },
  ["c"] = { "COMMAND", moon.yellow, "" },
  ["cv"] = { "EX", moon.yellow, "" },
  ["ce"] = { "EX", moon.yellow, "" },
  ["r"] = { "PROMPT", moon.teal, "" },
  ["rm"] = { "MORE", moon.teal, "" },
  ["r?"] = { "CONFIRM", moon.teal, "" },
  ["!"] = { "SHELL", moon.cyan, "" },
  ["t"] = { "TERMINAL", moon.cyan, "" },
}

-- Flat, fixed-color segments: just bold colored text on the base bg —
-- no pill/background block, so it stays legible in low-contrast themes.
local seg_defs = {
  { key = "lsp", name = "Lsp", color = moon.blue1 },
  { key = "macro", name = "Macro", color = moon.red },
  { key = "error", name = "Error", color = moon.red },
  { key = "warn", name = "Warn", color = moon.yellow },
  { key = "hint", name = "Hint", color = moon.teal },
  { key = "info", name = "Info", color = moon.cyan },
  { key = "session_saved", name = "SessionSaved", color = moon.green },
  { key = "session_unsaved", name = "SessionUnsaved", color = moon.orange },
}

-- Populated by set_statusline_colors(): key -> ready "%#Group#" string.
local seg_hl = {}

-- Define statusline highlight groups using the fixed Moon palette.
local function set_statusline_colors()
  local bg = moon.bg

  vim.api.nvim_set_hl(0, "SLBase", { fg = moon.fg, bg = bg })
  vim.api.nvim_set_hl(0, "SLDefault", { fg = moon.fg_dark, bg = bg })
  vim.api.nvim_set_hl(0, "SLDivider", { fg = moon.comment, bg = bg })
  -- Rightmost item: no bg block at all — inherits the statusline bg.
  vim.api.nvim_set_hl(0, "SLCursor", { fg = moon.fg, bold = true })

  for _, def in ipairs(seg_defs) do
    local name = "SL" .. def.name
    vim.api.nvim_set_hl(0, name, { fg = def.color, bg = bg, bold = true })
    seg_hl[def.key] = "%#" .. name .. "#"
  end

  -- Mode: bold colored text, no background block — just a bright label.
  for _, entry in pairs(mode_map) do
    local label, color = entry[1], entry[2]
    local hl_name = "SLMode" .. label:gsub("[^%a]", "")
    vim.api.nvim_set_hl(0, hl_name, { fg = color, bg = bg, bold = true })
  end
end

-- Render `content` in the flat segment style identified by `key`.
local function seg(key, content)
  return seg_hl[key] .. content .. "%#SLDefault#"
end

-- Thin, muted divider placed between visible segments.
local function divider()
  return "%#SLDivider#" .. icons.divider .. "%#SLDefault#"
end

set_statusline_colors()
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = set_statusline_colors,
})

-- Current mode, rendered as plain bold colored text (no block).
_G.get_mode = function()
  local m = vim.fn.mode()
  local entry = mode_map[m] or { "UNKNOWN", moon.fg_dark, "" }
  local label, _, icon = entry[1], entry[2], entry[3]
  local hl_name = "%#SLMode" .. label:gsub("[^%a]", "") .. "#"

  return hl_name .. icon .. " " .. label .. "%#SLDefault#"
end

-- Redraw the statusline on every mode change so the label stays in sync.
local mode_grp = vim.api.nvim_create_augroup("StatuslineModeRefresh", { clear = true })
vim.api.nvim_create_autocmd({ "ModeChanged" }, {
  group = mode_grp,
  callback = function()
    vim.cmd("redrawstatus")
  end,
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
    table.insert(parts, seg("error", icons.error .. " " .. e))
  end
  if w > 0 then
    table.insert(parts, seg("warn", icons.warn .. " " .. w))
  end
  if h > 0 then
    table.insert(parts, seg("hint", icons.hint .. " " .. h))
  end
  if i > 0 then
    table.insert(parts, seg("info", icons.info .. " " .. i))
  end

  if #parts == 0 then
    return ""
  end
  return table.concat(parts, " ")
end

-- Current macro recording register
_G.get_macro_recording = function()
  local reg = vim.fn.reg_recording()
  if reg == "" then
    return ""
  end
  return seg("macro", icons.macro .. " REC @" .. reg)
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
  local key = unsaved and "session_unsaved" or "session_saved"
  local icon = unsaved and icons.session_unsaved or icons.session_saved

  return seg(key, "Session: " ..  name .. icon .. " ")
end

-- Build the full statusline string
_G.build_statusline = function()
  local mode = _G.get_mode()
  local macro = _G.get_macro_recording()
  local lsp = seg("lsp", icons.lsp .. " " .. _G.get_lsp_count())
  local diag = _G.get_diagnostics()
  local session = _G.get_session()
  local cursor = "%#SLCursor#" .. icons.cursor .. " %l:%c"

  -- Collect only the segments that currently have content, then join
  -- them with a single thin divider — no empty " │ │ " gaps.
  local left = { mode }
  if macro ~= "" then
    table.insert(left, macro)
  end
  table.insert(left, lsp)
  if diag ~= "" then
    table.insert(left, diag)
  end
  if session ~= "" then
    table.insert(left, session)
  end

  local left_str = table.concat(left, " " .. divider() .. " ")

  --  LEFT: mode │ macro │ lsp │ diagnostics │ session
  -- RIGHT: cursor position
  return "%#SLBase# " .. left_str .. "%=" .. cursor .. " "
end

vim.o.statusline = "%!v:lua.build_statusline()"
