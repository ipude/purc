-- user/config/lsp/log.lua

local seen_errors = {}
local session_log = {}
local lsp_buf     = nil
local _in_notify  = false

local LOG_PATH = vim.fn.expand("~/.local/share/nvim/server/log.json")

vim.fn.mkdir(vim.fn.fnamemodify(LOG_PATH, ":h"), "p")

-- JSON ------------------------------------------------------------------------

local function read_json()
  local f = io.open(LOG_PATH, "r")
  if not f then return {} end
  local raw = f:read("*a"); f:close()
  if raw == "" then return {} end
  local ok, data = pcall(vim.fn.json_decode, raw)
  return (ok and type(data) == "table") and data or {}
end

local function write_json()
  local entries = vim.tbl_values(session_log)
  local lines   = { "[" }
  for i, e in ipairs(entries) do
    local comma = i < #entries and "," or ""
    table.insert(lines, string.format(
      '  { "log": %s, "timed_at": %s, "occurrence": %d }%s',
      vim.fn.json_encode(e.log),
      vim.fn.json_encode(e.timed_at),
      e.occurrence,
      comma
    ))
  end
  if #entries == 0 then lines = { "[]" } else table.insert(lines, "]") end
  local f = io.open(LOG_PATH, "w")
  if not f then return end
  f:write(table.concat(lines, "\n")); f:close()
end

local function fmt_time()
  return os.date("%H:%M:%S %A %B %Y")
end

-- Seed session_log from log.json on startup -----------------------------------

do
  for _, e in ipairs(read_json()) do
    if e.log and e.log ~= "" then
      session_log[e.log] = {
        log        = e.log,
        timed_at   = e.timed_at,
        occurrence = e.occurrence or 1,
      }
    end
  end
end

-- Fingerprint -----------------------------------------------------------------

local function fingerprint(msg)
  return msg
    :gsub("^[%w_%-]+:%s*",                "")
    :gsub("^%-?%d+:%s*",                  "")
    :gsub("^request handler panicked:%s*", "")
    :gsub("%s+", " ")
    :match("^%s*(.-)%s*$")
    :sub(1, 80)
end

-- Log entry -------------------------------------------------------------------

local function log_entry(raw)
  local uid = fingerprint(raw)
  if uid == "" then return end

  if session_log[uid] then
    session_log[uid].occurrence = session_log[uid].occurrence + 1
    session_log[uid].timed_at   = fmt_time()
  else
    -- Store `raw` (trimmed), not `uid`, so the client name is preserved
    local display = raw:match("^%s*(.-)%s*$"):sub(1, 120)
    session_log[uid] = { log = display, timed_at = fmt_time(), occurrence = 1 }
  end

  write_json()
end

-- notify_once -----------------------------------------------------------------

local function notify_once(uid)
  if seen_errors[uid] then return end
  seen_errors[uid] = true
  _in_notify = true
  vim.notify(
    "Lsp Rpc message!\nUrgently open server/log.json via given motions: ;l\nUid    : " .. uid .. "\n",
    vim.log.levels.WARN
  )
  _in_notify = false
end

-- Buffer ----------------------------------------------------------------------

local function get_or_create_buf()
  if lsp_buf and vim.api.nvim_buf_is_valid(lsp_buf) then return lsp_buf end
  lsp_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(lsp_buf, LOG_PATH)
  vim.bo[lsp_buf].buftype   = "nofile"
  vim.bo[lsp_buf].bufhidden = "hide"
  vim.bo[lsp_buf].swapfile  = false
  vim.bo[lsp_buf].filetype  = "json"
  return lsp_buf
end

local function refresh_buf()
  local buf = get_or_create_buf()
  local raw = read_json()
  local lines = { "[" }
  for i, e in ipairs(raw) do
    local comma = i < #raw and "," or ""
    table.insert(lines, string.format(
      '  { "log": %s, "timed_at": %s, "occurrence": %d }%s',
      vim.fn.json_encode(e.log),
      vim.fn.json_encode(e.timed_at),
      e.occurrence,
      comma
    ))
  end
  if #raw == 0 then lines = { "[]" } else table.insert(lines, "]") end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

local function toggle_buf()
  -- close if already open in any window
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == lsp_buf then
      vim.api.nvim_win_close(win, true)
      lsp_buf = nil
      return
    end
  end
  vim.cmd("edit " .. LOG_PATH)
  lsp_buf = vim.api.nvim_get_current_buf()
  local opts = { noremap = true, silent = true, buffer = lsp_buf }
  vim.keymap.set("n", "q",          "<cmd>bprev<cr>", opts)
end

vim.keymap.set("n", ";ll", "<cmd>e ~/.local/share/nvim/server/log.json<cr>", { noremap = true, silent = true, desc = "Toggle LSP log" })

-- LSP handlers ----------------------------------------------------------------

vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
  local c = vim.lsp.get_client_by_id(ctx.client_id)
  log_entry((c and c.name or "lsp") .. ": " .. result.message)
end

vim.lsp.handlers["window/logMessage"] = function(_, result, ctx)
  local c = vim.lsp.get_client_by_id(ctx.client_id)
  log_entry((c and c.name or "lsp") .. ": " .. result.message)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_log_on_error", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    local name = client.name
    local orig = client.on_error
    client.on_error = function(code, msg)
      log_entry(("[ERROR %s] %s"):format(code, msg or ""))
      if orig then orig(code, msg) end
    end
  end,
})

-- Intercepts ------------------------------------------------------------------

local orig_notify = vim.notify
local orig_echo   = vim.api.nvim_echo

local function is_from_lsp(msg)
  if type(msg) ~= "string" then return false end
  for _, client in pairs(vim.lsp.get_clients()) do
    if msg:find(client.name, 1, true) then return true end
  end
  return false
end

---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, opts)
  if _in_notify then orig_notify(msg, level, opts); return end
  if is_from_lsp(msg) then
    log_entry(msg)
    notify_once(fingerprint(msg))
    return
  end
  orig_notify(msg, level, opts)
end

---@diagnostic disable-next-line: duplicate-set-field
vim.api.nvim_echo = function(chunks, history, opts)
  if _in_notify then orig_echo(chunks, history, opts); return end
  local full = table.concat(vim.tbl_map(function(c) return c[1] or "" end, chunks))
  if is_from_lsp(full) then
    log_entry(full)
    notify_once(fingerprint(full))
    return
  end
  orig_echo(chunks, history, opts)
end
