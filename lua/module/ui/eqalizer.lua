local M = {}

local function hl_fg(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return (ok and hl.fg) and string.format("#%06x", hl.fg) or nil
end

local function hl_bg(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return (ok and hl.bg) and string.format("#%06x", hl.bg) or nil
end

local function first(...)
  for _, v in ipairs({ ... }) do
    if v ~= nil then
      return v
    end
  end
end

function M.setup()
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

  local function set_hls(groups)
    for _, spec in ipairs(groups) do
      vim.api.nvim_set_hl(0, spec[1], spec[2])
    end
  end

  set_hls({
    { "WinSeparator", { fg = border_fg, bold = true } },
    { "VertSplit", { fg = border_fg, bold = true } },
  })

  vim.g.float_border_style = "rounded"
  set_hls({
    { "FzfLuaNormal", { bg = bg, fg = fg } },
    { "FzfLuaBorder", { fg = border_fg, bg = bg, bold = true } },
    { "FzfLuaTitle", { fg = bg, bg = border_fg, bold = true } },
    { "FzfLuaPreviewNormal", { bg = bg, fg = fg } },
    { "FzfLuaPreviewBorder", { fg = border_fg, bg = bg, bold = true } },
    { "FzfLuaPreviewTitle", { fg = bg, bg = border_fg, bold = true } },
  })
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
