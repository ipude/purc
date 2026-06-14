-- diagnostics_panel.lua
-- Place in ~/.config/nvim/lua/diagnostics_panel.lua
-- Then require it in your init.lua: require("diagnostics_panel")

local M = {}

-- ── helpers ────────────────────────────────────────────────────────────────

local severity_label = {
  [vim.diagnostic.severity.ERROR]   = "Error",
  [vim.diagnostic.severity.WARN]    = "Warn",
  [vim.diagnostic.severity.INFO]    = "Info",
  [vim.diagnostic.severity.HINT]    = "Hint",
}

-- Map severity → letter prefix shown inside the list (a/b/c/d …)
-- We just use alphabetical letters per entry under a line.
local function letter(n)
  return string.char(string.byte("a") + n - 1) .. "."
end

-- Build the lines to display in the diagnostic buffer.
-- @param diags  list of vim.Diagnostic (already sorted)
-- @param cur_line  0-based current cursor line (nil if not applicable)
-- @return table of string lines, table of highlight specs {line, col_s, col_e, hl_group}
local function build_lines(diags, cur_line)
  -- Group by 1-based line number
  local by_line = {}   -- [lnum_1based] = { diag, ... }
  local order   = {}   -- unique lnums in appearance order

  for _, d in ipairs(diags) do
    local ln = d.lnum + 1   -- convert 0-based → 1-based for display
    if not by_line[ln] then
      by_line[ln] = {}
      table.insert(order, ln)
    end
    table.insert(by_line[ln], d)
  end

  -- Sort line numbers; current line first, rest ascending
  table.sort(order, function(a, b)
    local a_cur = (cur_line and a == cur_line + 1)
    local b_cur = (cur_line and b == cur_line + 1)
    if a_cur ~= b_cur then return a_cur end
    return a < b
  end)

  local lines  = {}
  local hls    = {}   -- { row (0-based), col_start, col_end, hl_group }

  local function add_hl(row, col_s, col_e, grp)
    table.insert(hls, { row = row, col_s = col_s, col_e = col_e, grp = grp })
  end

  for _, ln in ipairs(order) do
    local is_cur = cur_line and (ln == cur_line + 1)
    local header = "Line " .. ln .. (is_cur and "  ◀ current" or "") .. ":"

    -- blank separator (skip before very first)
    if #lines > 0 then
      table.insert(lines, "")
    end

    local hdr_row = #lines
    table.insert(lines, header)

    -- highlight "Line N:" part
    add_hl(hdr_row, 0, #("Line " .. ln .. ":"),
      is_cur and "DiagnosticPanelCurrentLine" or "DiagnosticPanelLineHeader")

    for i, d in ipairs(by_line[ln]) do
      local sev   = severity_label[d.severity] or "?"
      local col   = d.col + 1   -- 0-based → 1-based
      local msg   = d.message:gsub("\n", " ")
      local src   = d.source and (" [" .. d.source .. "]") or ""
      local loc   = string.format("(col %d)", col)

      -- Format:  a. [Error] (col 4) message [source]
      local entry = string.format("  %s [%s] %s %s%s", letter(i), sev, loc, msg, src)
      local entry_row = #lines
      table.insert(lines, entry)

      -- colour the severity badge
      local badge_s = 2 + #letter(i) + 1   -- after "  a. "
      local badge_e = badge_s + #("[" .. sev .. "]")
      local hl_map = {
        Error = "DiagnosticError",
        Warn  = "DiagnosticWarn",
        Info  = "DiagnosticInfo",
        Hint  = "DiagnosticHint",
      }
      add_hl(entry_row, badge_s, badge_e, hl_map[sev] or "Normal")
    end
  end

  if #lines == 0 then
    table.insert(lines, "  ✓  No diagnostics for this buffer.")
  end

  return lines, hls
end

-- ── buffer / window creation ───────────────────────────────────────────────

local panel_bufnr = nil
local panel_winid = nil

local function is_valid_panel()
  return panel_bufnr
    and vim.api.nvim_buf_is_valid(panel_bufnr)
    and panel_winid
    and vim.api.nvim_win_is_valid(panel_winid)
end

local function close_panel()
  if panel_winid and vim.api.nvim_win_is_valid(panel_winid) then
    vim.api.nvim_win_close(panel_winid, true)
  end
  if panel_bufnr and vim.api.nvim_buf_is_valid(panel_bufnr) then
    vim.api.nvim_buf_delete(panel_bufnr, { force = true })
  end
  panel_bufnr = nil
  panel_winid = nil
end

local function open_panel(source_win, source_buf)
  -- If panel already open → close (toggle)
  if is_valid_panel() then
    close_panel()
    return
  end

  -- Remember which window/buf we're diagnosing
  local target_win = source_win or vim.api.nvim_get_current_win()
  local target_buf = source_buf or vim.api.nvim_get_current_buf()
  local cur_line   = vim.api.nvim_win_get_cursor(target_win)[1] - 1  -- 0-based

  -- Gather & sort diagnostics (errors first, then by line)
  local diags = vim.diagnostic.get(target_buf)
  table.sort(diags, function(a, b)
    if a.lnum ~= b.lnum then return a.lnum < b.lnum end
    if a.severity ~= b.severity then return a.severity < b.severity end
    return a.col < b.col
  end)

  local lines, hls = build_lines(diags, cur_line)

  -- Create scratch buffer
  panel_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(panel_bufnr, 0, -1, false, lines)
  vim.bo[panel_bufnr].modifiable  = false
  vim.bo[panel_bufnr].buftype     = "nofile"
  vim.bo[panel_bufnr].filetype    = "diagnostics_panel"
  vim.bo[panel_bufnr].bufhidden   = "wipe"

  -- Apply highlights
  local ns = vim.api.nvim_create_namespace("diagnostics_panel_hl")
  for _, h in ipairs(hls) do
    vim.api.nvim_buf_add_highlight(panel_bufnr, ns, h.grp, h.row, h.col_s, h.col_e)
  end

  -- Open horizontal split below
  vim.cmd("botright 14split")
  panel_winid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(panel_winid, panel_bufnr)

  -- Window options
  local wo = vim.wo[panel_winid]
  wo.number         = false
  wo.relativenumber = false
  wo.signcolumn     = "no"
  wo.wrap           = true
  wo.cursorline     = false
  wo.foldcolumn     = "0"
  wo.winfixheight   = true

  -- q / Escape to close
  vim.keymap.set("n", "q",      close_panel, { buffer = panel_bufnr, silent = true })
  vim.keymap.set("n", "<Esc>",  close_panel, { buffer = panel_bufnr, silent = true })

  -- Jump back to the source window
  vim.api.nvim_set_current_win(target_win)
end

-- ── highlight groups (define once, respect colorscheme reloads) ───────────

local function setup_highlights()
  vim.api.nvim_set_hl(0, "DiagnosticPanelLineHeader",    { link = "Title",       default = true })
  vim.api.nvim_set_hl(0, "DiagnosticPanelCurrentLine",   { link = "WarningMsg",  default = true })
end

-- ── keymaps ───────────────────────────────────────────────────────────────

function M.setup(opts)
  opts = opts or {}

  setup_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = setup_highlights,
    desc     = "Re-apply DiagnosticPanel highlights after colorscheme change",
  })

  -- <End>  → buffer diagnostics panel
  vim.keymap.set("n", "<End>", function()
    open_panel(vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf())
  end, { silent = true, desc = "Toggle buffer diagnostic panel" })

  -- <S-End> → workspace (not yet implemented)
  vim.keymap.set("n", "<S-End>", function()
    vim.notify(
      "Workspace diagnostic is unavailable and may be added in the future if needed.\n"
      .. "For urgent need either use Trouble or prompt AI to make something similar to the local one.",
      vim.log.levels.INFO,
      { title = "Workspace Diagnostics" }
    )
  end, { silent = true, desc = "Workspace diagnostic (unavailable)" })
end

return M
