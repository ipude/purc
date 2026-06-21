-- user/config/lsp/log.lua

local lsp_buf = nil
local lsp_tab = nil
local seen_errors = {}

local function get_or_create_buf()
  if lsp_buf and vim.api.nvim_buf_is_valid(lsp_buf) then return lsp_buf end
  lsp_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(lsp_buf, "lsp-log")
  vim.bo[lsp_buf].buftype   = "nofile"
  vim.bo[lsp_buf].bufhidden = "hide"
  vim.bo[lsp_buf].swapfile  = false
  vim.bo[lsp_buf].filetype  = "log"
  return lsp_buf
end

local function append(source, msg)
  local buf = get_or_create_buf()
  local timestamp = os.date("%H:%M:%S")
  local lines = vim.split(("[%s] [%s] %s"):format(timestamp, source, msg), "\n")
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
end

local function is_tab_open()
  if not lsp_tab then return false end
  for _, t in ipairs(vim.api.nvim_list_tabpages()) do
    if t == lsp_tab then return true end
  end
  lsp_tab = nil
  return false
end

local function open_tab()
  local buf = get_or_create_buf()
  vim.cmd("tabnew")
  lsp_tab = vim.api.nvim_get_current_tabpage()
  vim.api.nvim_set_current_buf(buf)
  local win = vim.api.nvim_get_current_win()
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("n", "q",          function() vim.cmd("tabclose"); lsp_tab = nil end, opts)
  vim.keymap.set("n", "<leader>ll", function() vim.cmd("tabclose"); lsp_tab = nil end, opts)
  vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
end

local function toggle()
  if is_tab_open() then
    vim.api.nvim_set_current_tabpage(lsp_tab)
    vim.cmd("tabclose")
    lsp_tab = nil
  else
    open_tab()
  end
end

vim.keymap.set("n", "<leader>ll", toggle, { noremap = true, silent = true, desc = "Toggle LSP log" })

-- LSP notification handlers ---------------------------------------------------

vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  append(client and client.name or "lsp", result.message)
end

vim.lsp.handlers["window/logMessage"] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  append(client and client.name or "lsp", result.message)
end

-- LspAttach: patch on_error on live client ------------------------------------

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_log_on_error", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    local name = client.name
    local orig = client.on_error
    client.on_error = function(code, msg)
      append(name, ("[ERROR %s] %s"):format(code, msg or ""))
      if orig then orig(code, msg) end
    end
  end,
})

-- Save originals BEFORE overrides ---------------------------------------------
-- Save originals BEFORE overrides
local orig_notify = vim.notify
local orig_echo   = vim.api.nvim_echo

local function notify_once(msg)
  local uid = msg
    :gsub("rust_analyzer:%s*", "")
    :gsub("%-?%d+:%s*", "")
    :gsub("request handler panicked:%s*", "")
    :gsub("%s+", " ")
    :match("^%s*(.-)%s*$")
    :sub(1, 60)

  if seen_errors[uid] then return end
  seen_errors[uid] = true

  orig_notify(
    "LSP panicked!\nUid : " .. uid .. "\nUsage : <space>ll",
    vim.log.levels.WARN
  )
end

-- Intercept nvim_echo and re-route via vim.notify ----------------------------

---@diagnostic disable-next-line: duplicate-set-field
vim.api.nvim_echo = function(chunks, history, opts)
  local full = table.concat(vim.tbl_map(function(c) return c[1] or "" end, chunks))
  if full:find("request handler panicked") or full:find("-32603") or full:find("failed to unify") then
    append("lsp", full)
    notify_once(full)
    return
  end
  orig_echo(chunks, history, opts)
end

-- Intercept vim.notify --------------------------------------------------------

---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, opts)
  if type(msg) == "string" and (
    msg:find("request handler panicked") or
    msg:find("-32603") or
    msg:find("failed to unify")
  ) then
    append("lsp", msg)
    notify_once(msg)
    return
  end
  orig_notify(msg, level, opts)
end
