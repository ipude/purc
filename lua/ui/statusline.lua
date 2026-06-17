-- statusline.lua

local sep_r = ""
local sep_l = ""

-- Pull colors live from whatever theme is active
local function get_color(hl_group, attr)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_group, link = false })
  if not ok then
    return nil
  end
  local val = hl[attr]
  if not val then
    return nil
  end
  return string.format("#%06x", val)
end

local function setup_highlights()
  -- Sample the theme's own colors
  local blue = get_color("Function", "fg") or "#7aa2f7"
  local green = get_color("String", "fg") or "#9ece6a"
  local purple = get_color("Keyword", "fg") or "#bb9af7"
  local yellow = get_color("Type", "fg") or "#e0af68"
  local red = get_color("DiagnosticError", "fg") or "#f7768e"
  local cyan = get_color("DiagnosticInfo", "fg") or "#7dcfff"
  local fg = get_color("Normal", "fg") or "#c0caf5"
  local bg = get_color("Normal", "bg") or "#1a1b26"
  local surface = get_color("CursorLine", "bg") or "#1e2030"
  local muted = get_color("Comment", "fg") or "#565f89"

  -- Derive a slightly lighter surface for the bar itself
  local bar_bg = get_color("StatusLine", "bg") or surface

  local function mode_hl(accent)
    return { fg = bg, bg = accent, bold = true }
  end
  local function sep_hl(accent)
    return { fg = accent, bg = bar_bg }
  end

  local hls = {
    SlNormal = mode_hl(blue),
    SlNormalSep = sep_hl(blue),
    SlInsert = mode_hl(green),
    SlInsertSep = sep_hl(green),
    SlVisual = mode_hl(purple),
    SlVisualSep = sep_hl(purple),
    SlCommand = mode_hl(yellow),
    SlCommandSep = sep_hl(yellow),
    SlReplace = mode_hl(red),
    SlReplaceSep = sep_hl(red),
    SlTerminal = mode_hl(cyan),
    SlTerminalSep = sep_hl(cyan),

    SlRec = { fg = bg, bg = red, bold = true },
    SlRecSep = { fg = red, bg = bar_bg },

    SlLsp = { fg = cyan, bg = bar_bg },
    SlInfo = { fg = muted, bg = bar_bg },
    SlMod = { fg = yellow, bg = bar_bg, bold = true },

    SlPosBg = { fg = fg, bg = surface, bold = true },
    SlPosSepL = { fg = surface, bg = bar_bg },

    SlBase = { fg = fg, bg = bar_bg },
    SlBar = { fg = fg, bg = bar_bg },
  }

  for name, opts in pairs(hls) do
    vim.api.nvim_set_hl(0, name, opts)
  end
end

setup_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_highlights })

-- ─── Mode ────────────────────────────────────────────────────────────────────

local mode_map = {
  n = { label = "  NORMAL", base = "SlNormal", sep = "SlNormalSep" },
  i = { label = "  INSERT", base = "SlInsert", sep = "SlInsertSep" },
  v = { label = "  VISUAL", base = "SlVisual", sep = "SlVisualSep" },
  V = { label = "  V-LINE", base = "SlVisual", sep = "SlVisualSep" },
  ["\22"] = { label = "  V-BLOCK", base = "SlVisual", sep = "SlVisualSep" },
  c = { label = "  COMMAND", base = "SlCommand", sep = "SlCommandSep" },
  R = { label = "  REPLACE", base = "SlReplace", sep = "SlReplaceSep" },
  t = { label = "  TERMINAL", base = "SlTerminal", sep = "SlTerminalSep" },
  s = { label = "  SELECT", base = "SlVisual", sep = "SlVisualSep" },
  S = { label = "  S-LINE", base = "SlVisual", sep = "SlVisualSep" },
}

_G.sl_mode = function()
  local m = vim.fn.mode()
  local info = mode_map[m] or { label = "   " .. m, base = "SlNormal", sep = "SlNormalSep" }
  return "%#" .. info.base .. "# " .. info.label .. " %#" .. info.sep .. "#" .. sep_r .. "%#SlBase# "
end

-- ─── Recording ───────────────────────────────────────────────────────────────

_G.sl_recording = function()
  local reg = vim.fn.reg_recording()
  if reg == "" then
    return ""
  end
  return " %#SlRecSep#" .. sep_l .. "%#SlRec#  REC @" .. reg .. " %#SlRecSep#" .. sep_r .. "%#SlBase# "
end

-- ─── Modified / readonly ─────────────────────────────────────────────────────

_G.sl_flags = function()
  local mod = vim.bo.modified and "%#SlMod# ● " or ""
  local ro = vim.bo.readonly and "%#SlInfo# 󰌾 " or ""
  return mod .. ro
end

-- ─── LSP + diagnostics ───────────────────────────────────────────────────────

_G.sl_lsp = function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end

  local names = vim
    .iter(clients)
    :map(function(c)
      return c.name
    end)
    :totable()
  local out = "%#SlLsp#󰒋 " .. table.concat(names, ", ")

  -- Individual diagnostic counts with theme colors
  local icons = { error = " ", warn = " ", hint = "󰌶 ", info = " " }
  local dhl = { error = "DiagnosticError", warn = "DiagnosticWarn", hint = "DiagnosticHint", info = "DiagnosticInfo" }
  local counts = vim.diagnostic.count(0)
  local sev = vim.diagnostic.severity

  for _, key in ipairs({ "error", "warn", "hint", "info" }) do
    local s = sev[key:upper()]
    local n = counts[s] or 0
    if n > 0 then
      out = out .. " %#" .. dhl[key] .. "#" .. icons[key] .. n
    end
  end

  return out .. " "
end

-- ─── Position ────────────────────────────────────────────────────────────────

_G.sl_pos = function()
  return "%#SlPosSepL#" .. sep_l .. "%#SlPosBg#  %l:%c  %#SlPosSepL#" .. sep_r .. "%#SlInfo# 󰉸 %P "
end

-- ─── Assemble ────────────────────────────────────────────────────────────────

vim.opt.statusline = table.concat({
  "%#SlBar#",
  "%{%v:lua.sl_mode()%}",
  "%{%v:lua.sl_recording()%}",
  "%{%v:lua.sl_flags()%}",
  "%#SlBase#%=",
  "%{%v:lua.sl_lsp()%}",
  "%{%v:lua.sl_pos()%}",
})
