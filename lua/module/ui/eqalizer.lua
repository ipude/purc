local M = {}

local function hl_fg(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return (ok and hl.fg) and string.format("#%06x", hl.fg) or nil
end

local function hl_bg(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return (ok and hl.bg) and string.format("#%06x", hl.bg) or nil
end

--- Return the first non-nil value from a list of candidates.
local function first(...)
  for _, v in ipairs({ ... }) do
    if v ~= nil then
      return v
    end
  end
end

function M.setup()
  -- ── Palette ────────────────────────────────────────────────────────────
  local bg = hl_bg("Normal") or "#1e1e2e"
  local fg = hl_fg("Normal") or "#cdd6f4"
  local border_fg = first(hl_fg("Special"), hl_fg("Identifier"), hl_fg("NonText"), fg)
  local accent = first(hl_fg("Special"), hl_fg("Function"), border_fg)
  local muted = first(hl_fg("Comment"), hl_fg("NonText"), fg)
  local sel_bg = first(hl_bg("Visual"), hl_bg("CursorLine"), hl_bg("PmenuSel"), bg)
  local warn_fg = first(hl_fg("DiagnosticWarn"), hl_fg("WarningMsg"), "#ffaa00")
  local info_fg = first(hl_fg("DiagnosticInfo"), hl_fg("Special"), "#89dceb")
  local ok_fg = first(hl_fg("DiagnosticOk"), hl_fg("String"), "#00ff88")
  local err_fg = first(hl_fg("DiagnosticError"), hl_fg("ErrorMsg"), "#f38ba8")

  -- ── Helper ─────────────────────────────────────────────────────────────
  --- Batch-set highlight groups from a table of { GroupName, opts } pairs.
  local function set_hls(groups)
    for _, spec in ipairs(groups) do
      vim.api.nvim_set_hl(0, spec[1], spec[2])
    end
  end

  -- ── Core floats / borders / splits ─────────────────────────────────────
  set_hls({
    { "NormalFloat", { bg = bg, fg = fg } },
    { "FloatTitle", { fg = bg, bg = border_fg, bold = true } },
    { "FloatBorder", { fg = border_fg, bg = bg, bold = true } },
    { "WinSeparator", { fg = border_fg, bold = true } },
    { "VertSplit", { fg = border_fg, bold = true } },
  })

  vim.g.float_border_style = "rounded"

  -- ── fzf-lua ────────────────────────────────────────────────────────────
  set_hls({
    { "FzfLuaNormal", { bg = bg, fg = fg } },
    { "FzfLuaBorder", { fg = border_fg, bg = bg, bold = true } },
    { "FzfLuaTitle", { fg = bg, bg = border_fg, bold = true } },
    { "FzfLuaPreviewNormal", { bg = bg, fg = fg } },
    { "FzfLuaPreviewBorder", { fg = border_fg, bg = bg, bold = true } },
    { "FzfLuaPreviewTitle", { fg = bg, bg = border_fg, bold = true } },
    { "FzfLuaCursor", { fg = accent, bold = true } },
    { "FzfLuaCursorLine", { bg = sel_bg } },
    { "FzfLuaCursorLineNr", { fg = accent, bold = true } },
    { "FzfLuaScrollBorder", { fg = border_fg } },
    { "FzfLuaScrollFloat", { fg = border_fg } },
    { "FzfLuaHelpNormal", { bg = bg, fg = fg } },
    { "FzfLuaHelpBorder", { fg = border_fg, bg = bg, bold = true } },
    { "FzfLuaHeaderBind", { fg = accent } },
    { "FzfLuaHeaderText", { fg = muted } },
    { "FzfLuaPathColNr", { fg = info_fg } },
    { "FzfLuaPathLineNr", { fg = ok_fg } },
    { "FzfLuaBufName", { fg = accent } },
    { "FzfLuaBufNr", { fg = muted } },
    { "FzfLuaBufFlagCur", { fg = accent, bold = true } },
    { "FzfLuaBufFlagAlt", { fg = info_fg } },
    { "FzfLuaTabTitle", { fg = accent, bold = true } },
    { "FzfLuaTabMarker", { fg = ok_fg, bold = true } },
    { "FzfLuaDirIcon", { fg = accent } },
    { "FzfLuaFilePart", { fg = fg } },
    { "FzfLuaDirPart", { fg = muted } },
    { "FzfLuaLiveSym", { fg = ok_fg } },
  })

  -- ── mini.notify ────────────────────────────────────────────────────────
  set_hls({
    { "MiniNotifyBorder", { fg = border_fg, bg = bg, bold = true } },
    { "MiniNotifyNormal", { bg = bg, fg = fg } },
    { "MiniNotifyTitle", { fg = bg, bg = border_fg, bold = true } },
    { "MiniNotifyWindowTooTall", { fg = warn_fg } },
  })

  -- ── Diagnostics (virtual text + signs unified) ─────────────────────────
  set_hls({
    { "DiagnosticVirtualTextError", { fg = err_fg, bg = bg, italic = false } },
    { "DiagnosticVirtualTextWarn", { fg = warn_fg, bg = bg, italic = false } },
    { "DiagnosticVirtualTextInfo", { fg = info_fg, bg = bg, italic = false } },
    { "DiagnosticVirtualTextOk", { fg = ok_fg, bg = bg, italic = false } },
    { "DiagnosticSignError", { fg = err_fg, bold = true } },
    { "DiagnosticSignWarn", { fg = warn_fg, bold = true } },
    { "DiagnosticSignInfo", { fg = info_fg, bold = true } },
    { "DiagnosticSignOk", { fg = ok_fg, bold = true } },
  })
  -- ── blink.cmp ─────────────────────────────────────────────────────────────
  set_hls({
    -- Menu window
    { "BlinkCmpMenu", { bg = bg, fg = fg } },
    { "BlinkCmpMenuBorder", { fg = border_fg, bg = bg, bold = true } },
    { "BlinkCmpMenuSelection", { bg = sel_bg, bold = true } },

    -- Matched characters
    { "BlinkCmpLabelMatch", { fg = accent, bold = true } },

    -- Label / detail / description
    { "BlinkCmpLabel", { fg = fg } },
    { "BlinkCmpLabelDetail", { fg = muted, italic = false } },
    { "BlinkCmpLabelDescription", { fg = muted, italic = false } },

    -- Deprecated items
    { "BlinkCmpLabelDeprecated", { fg = muted, strikethrough = true } },

    -- Ghost text (inline preview)
    { "BlinkCmpGhostText", { fg = muted, italic = false } },

    -- Signature-help float
    { "BlinkCmpSignatureHelpBorder", { fg = border_fg, bg = bg, bold = true } },
    { "BlinkCmpSignatureHelp", { bg = bg, fg = fg } },
    { "BlinkCmpSignatureHelpActiveParameter", { fg = accent, bold = true, underline = true } },

    -- Kind icons — one entry per LSP kind using your palette colours
    { "BlinkCmpKindText", { fg = fg } },
    { "BlinkCmpKindMethod", { fg = accent } },
    { "BlinkCmpKindFunction", { fg = accent } },
    { "BlinkCmpKindConstructor", { fg = accent } },
    { "BlinkCmpKindField", { fg = info_fg } },
    { "BlinkCmpKindVariable", { fg = info_fg } },
    { "BlinkCmpKindProperty", { fg = info_fg } },
    { "BlinkCmpKindClass", { fg = warn_fg } },
    { "BlinkCmpKindInterface", { fg = warn_fg } },
    { "BlinkCmpKindStruct", { fg = warn_fg } },
    { "BlinkCmpKindEnum", { fg = warn_fg } },
    { "BlinkCmpKindEnumMember", { fg = ok_fg } },
    { "BlinkCmpKindModule", { fg = border_fg } },
    { "BlinkCmpKindUnit", { fg = ok_fg } },
    { "BlinkCmpKindValue", { fg = ok_fg } },
    { "BlinkCmpKindKeyword", { fg = err_fg } },
    { "BlinkCmpKindSnippet", { fg = ok_fg, italic = false } },
    { "BlinkCmpKindColor", { fg = ok_fg } },
    { "BlinkCmpKindFile", { fg = muted } },
    { "BlinkCmpKindReference", { fg = muted } },
    { "BlinkCmpKindFolder", { fg = muted } },
    { "BlinkCmpKindEvent", { fg = warn_fg } },
    { "BlinkCmpKindOperator", { fg = fg } },
    { "BlinkCmpKindTypeParameter", { fg = warn_fg } },
    { "BlinkCmpKindCopilot", { fg = ok_fg, italic = false } },
  })
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = M.setup })
M.setup()

return M
