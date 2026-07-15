-- ~/.config/nvim/lua/user/session.lua
--
-- Custom session manager built directly on Neovim's native
-- :mksession / :source API (no session plugin), with fzf-lua pickers.
--
-- Keymaps:
--   <leader>sf  Session Find   -> fuzzy pick + (re)load a session fresh
--   <leader>sc  Session Create -> new session, fails if name already exists
--   <leader>sd  Session Delete -> persistent fzf multi-delete (ctrl-x)
--   <leader>ss  Session Save   -> force an immediate manual save
--
-- Autosave: once a session is loaded/created, any new buffer, split,
-- or tab schedules a debounced save (AUTOSAVE_DELAY_MS after the last
-- change). A final synchronous save also runs on VimLeavePre if a
-- session is loaded, so quitting never loses state even mid-debounce.
--
-- Requires: fzf-lua (https://github.com/ibhagwan/fzf-lua)
--
-- Global state (exposed for use from other config files):
--   _G.PuSessionLoaded   -> false, or the loaded session's name (string)
--   _G.PuSessionUnsaved  -> true while a debounced autosave is pending
--                           (briefly true between a change and the
--                           autosave firing; false once it lands)
--   _G.PuSessionSnapshot -> internal baseline snapshot (buffers/splits/
--                           tabs) taken at load/save time; exposed
--                           mainly for debugging/inspection

local M = {}
local uv = vim.loop
local fzf = require("fzf-lua")

-- All sessions live here, one file per session, named by the user.
M.session_dir = vim.fn.stdpath("data") .. "/PuSession/"

-- Tracks the name of whatever session is currently "active" in this
-- editor instance (set on create/load). Autosave and <leader>ss both
-- write to this.
M.current_session = nil

-- How long to wait after the last new buffer/split/tab before
-- autosaving. Debounced so a burst of changes (e.g. opening several
-- files at once) collapses into one mksession call.
M.autosave_delay_ms = 10000

-- Global, cross-file accessible state. Initialize once up front so any
-- other file can safely read these even before a session is touched.
_G.PuSessionLoaded = false
_G.PuSessionUnsaved = false
_G.PuSessionSnapshot = nil

-- sessionoptions is the single biggest lever here:
--   - NO "curdir"/"sesdir"  -> Vim stores each buffer's *full absolute
--     path* in the session file instead of paths relative to a cwd
--     that may not exist/match next time you load it.
--   - NO "blank"/"terminal" -> no empty scratch buffers or dead
--     terminal jobs get "restored" as stale placeholders.
--   - buffers,tabpages,winsize,winpos,folds -> full layout (splits,
--     tabs, fold state) is captured and restored exactly.
vim.o.sessionoptions = "buffers,tabpages,winsize,winpos,folds,localoptions,globals,help"

local function ensure_dir()
  if vim.fn.isdirectory(M.session_dir) == 0 then
    vim.fn.mkdir(M.session_dir, "p")
  end
end

local function session_path(name)
  return M.session_dir .. name .. ".vim"
end

local function file_exists(path)
  return vim.fn.filereadable(path) == 1
end

local function list_sessions()
  ensure_dir()
  local files = vim.fn.globpath(M.session_dir, "*.vim", false, true)
  local names = {}
  for _, f in ipairs(files) do
    table.insert(names, vim.fn.fnamemodify(f, ":t:r"))
  end
  table.sort(names)
  return names
end

-- Nuke all buffers/windows/tabs before loading a session so what you
-- get is EXACTLY what's in the session file — never a merge with
-- whatever happened to already be open (i.e. always fresh, never stale).
local function reset_editor_state()
  vim.cmd("silent! tabonly")
  vim.cmd("silent! only")
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end

-- ---------------------------------------------------------------------
-- Snapshotting: capture the "shape" of the editor (listed buffers, plus
-- window/tab layout) right after a session is loaded or saved. This is
-- the baseline that later buffer/window/tab *creation* events get
-- diffed against to decide whether the live state has drifted from
-- what's on disk.
-- ---------------------------------------------------------------------

local function listed_buffer_paths()
  local set = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" then
        set[vim.fn.fnamemodify(name, ":p")] = true
      end
    end
  end
  return set
end

local function window_count_per_tab()
  local counts = {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    counts[tab] = #vim.api.nvim_tabpage_list_wins(tab)
  end
  return counts
end

local function capture_snapshot()
  return {
    buffers = listed_buffer_paths(),
    tab_windows = window_count_per_tab(),
    tab_count = #vim.api.nvim_list_tabpages(),
  }
end

-- True only when something NEW has appeared relative to `snapshot`:
-- a listed buffer that wasn't there before, an extra tab, or an extra
-- window (split) in some tab. Removals are ignored on purpose — we
-- only care about *additions* per the spec. This function is only ever
-- invoked from creation-type autocmds (BufAdd/WinNew/TabNew), so plain
-- navigation (bufnext/bufprev/tabnext/tabprev, <C-w>w, etc.) never even
-- reaches this comparison.
local function has_new_entities(snapshot)
  if not snapshot then
    return false
  end

  for path, _ in pairs(listed_buffer_paths()) do
    if not snapshot.buffers[path] then
      return true
    end
  end

  local cur_tab_count = #vim.api.nvim_list_tabpages()
  if cur_tab_count > snapshot.tab_count then
    return true
  end

  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local cur_wins = #vim.api.nvim_tabpage_list_wins(tab)
    local old_wins = snapshot.tab_windows[tab]
    if old_wins == nil or cur_wins > old_wins then
      return true
    end
  end

  return false
end

-- Call this right after a successful create/load/save: marks the
-- session as loaded, records its name, takes a fresh baseline
-- snapshot, and clears the unsaved/pending flags.
local function mark_loaded(name)
  M.current_session = name
  _G.PuSessionLoaded = name
  _G.PuSessionUnsaved = false
  _G.PuSessionSnapshot = capture_snapshot()
end

-- Call this when there's no longer an active session (e.g. it was
-- deleted out from under us).
local function mark_unloaded()
  M.current_session = nil
  _G.PuSessionLoaded = false
  _G.PuSessionUnsaved = false
  _G.PuSessionSnapshot = nil
end

-- ---------------------------------------------------------------------
-- Autosave: debounced write to the active session file. Any
-- buffer/split/tab creation (re)schedules this timer; it collapses
-- bursts of changes into a single mksession call.
-- ---------------------------------------------------------------------

local autosave_timer = nil

local function stop_autosave_timer()
  if autosave_timer then
    autosave_timer:stop()
    autosave_timer:close()
    autosave_timer = nil
  end
end

-- Performs the actual write. Safe to call even if nothing is loaded
-- (no-ops). Runs on the libuv loop, so hop back to the main loop via
-- vim.schedule before touching vim.* APIs.
local function do_autosave()
  stop_autosave_timer()
  if not M.current_session then
    return
  end
  vim.cmd("mksession! " .. vim.fn.fnameescape(session_path(M.current_session)))
  mark_loaded(M.current_session)
end

local function schedule_autosave()
  if not M.current_session then
    return
  end
  stop_autosave_timer()
  autosave_timer = uv.new_timer()
  autosave_timer:start(M.autosave_delay_ms, 0, vim.schedule_wrap(do_autosave))
end

-- Invoked from BufAdd/WinNew/TabNew only. No-ops if no session is
-- currently loaded. Marks the pending state and (re)arms the
-- debounced autosave.
local function check_unsaved()
  if not _G.PuSessionLoaded then
    return
  end
  if has_new_entities(_G.PuSessionSnapshot) then
    _G.PuSessionUnsaved = true
    schedule_autosave()
  end
end

--- Returns the loaded session's name (truthy string) if a session is
--- currently loaded, or `false` otherwise.
function M.is_session_loaded()
  return _G.PuSessionLoaded
end

--- Returns true if an autosave is currently pending (debounce window
--- hasn't fired yet) or otherwise not yet flushed to disk.
function M.is_unsaved()
  return _G.PuSessionUnsaved
end

--- <leader>ss — Session Save
-- Forces an immediate save, bypassing the debounce. Useful right
-- before you know you're about to quit or hand off. If nothing is
-- active yet (fresh nvim, never created/loaded one), prompts for a
-- name so save never silently no-ops.
function M.session_save()
  ensure_dir()
  if not M.current_session then
    vim.ui.input({ prompt = "No active session — name for new session: " }, function(name)
      if not name or name == "" then
        vim.notify("Session save cancelled", vim.log.levels.WARN)
        return
      end
      if file_exists(session_path(name)) then
        vim.notify("Session '" .. name .. "' already exists", vim.log.levels.ERROR)
        return
      end
      vim.cmd("mksession! " .. vim.fn.fnameescape(session_path(name)))
      mark_loaded(name)
      vim.notify("Session created & saved: " .. name)
    end)
    return
  end

  stop_autosave_timer()
  do_autosave()
end

--- <leader>sc — Session Create
-- Name must be unique; refuses (does not overwrite) if it exists.
-- Once created, the session becomes the autosave target.
function M.session_create()
  ensure_dir()
  vim.ui.input({ prompt = "New session name: " }, function(name)
    if not name or name == "" then
      vim.notify("Session create cancelled", vim.log.levels.WARN)
      return
    end
    if file_exists(session_path(name)) then
      vim.notify("Session '" .. name .. "' already exists", vim.log.levels.ERROR)
      return
    end
    vim.cmd("mksession! " .. vim.fn.fnameescape(session_path(name)))
    mark_loaded(name)
    vim.notify("Session created (autosave enabled): " .. name)
  end)
end

--- <leader>sf — Session Find / Load
-- Fuzzy-pick a session from PuSession/ and load it fresh (reset first).
-- Once loaded, the session becomes the autosave target.
function M.session_find()
  ensure_dir()
  local sessions = list_sessions()
  if #sessions == 0 then
    vim.notify("No sessions found in " .. M.session_dir, vim.log.levels.WARN)
    return
  end

  fzf.fzf_exec(sessions, {
    prompt = "Sessions❯ ",
    fzf_opts = { ["--no-multi"] = "" },
    actions = {
      ["default"] = function(selected)
        if not selected or #selected == 0 then
          return
        end
        local name = selected[1]
        local path = session_path(name)
        if not file_exists(path) then
          vim.notify("Session file missing: " .. path, vim.log.levels.ERROR)
          return
        end
        reset_editor_state()
        vim.cmd("silent! source " .. vim.fn.fnameescape(path))
        mark_loaded(name)
        vim.notify("Loaded session (autosave enabled): " .. name)
      end,
    },
  })
end

--- <leader>sd — Session Delete
-- Persistent multi-select fzf deleter: ctrl-x deletes the highlighted
-- entry/entries and reloads the list IN PLACE — the fzf window never
-- closes, so you can keep bulk-deleting until you hit <Esc>.
function M.session_delete()
  ensure_dir()
  local sessions = list_sessions()
  if #sessions == 0 then
    vim.notify("No sessions to delete", vim.log.levels.INFO)
    return
  end

  -- fzf-lua's fzf_exec wants an actual table of entries (same as
  -- session_find below) — a lua function that just returns a table is
  -- NOT a valid contents provider and silently yields an empty list.
  fzf.fzf_exec(sessions, {
    prompt = "Delete Session(s) <C-x>❯ ",
    fzf_opts = { ["--multi"] = "" },
    actions = {
      ["default"] = false, -- disable enter; this picker is delete-only
      ["ctrl-x"] = function(selected)
        if not selected or #selected == 0 then
          return
        end
        for _, name in ipairs(selected) do
          local path = session_path(name)
          if file_exists(path) then
            if uv.fs_unlink(path) then
              if M.current_session == name then
                stop_autosave_timer()
                mark_unloaded()
              end
              vim.notify("Deleted session: " .. name)
            else
              vim.notify("Failed to delete: " .. name, vim.log.levels.ERROR)
            end
          end
        end
        -- Re-open the picker with the refreshed list immediately, so
        -- bulk-deleting feels continuous even though fzf itself can't
        -- truly "reload in place" from a static-table contents source.
        vim.schedule(M.session_delete)
      end,
    },
  })
end

-- ---------------------------------------------------------------------
-- Autocmds: ONLY creation-type events. BufAdd fires when a buffer is
-- newly added to the buffer list (e.g. :edit a new file) — never when
-- switching to an already-listed buffer (that's BufEnter, deliberately
-- not hooked). WinNew fires on splits/vsplits, never on <C-w>w focus
-- changes. TabNew fires on new tabs, never on tabnext/tabprev. This is
-- what keeps autosave from ever triggering on plain navigation.
-- ---------------------------------------------------------------------
local aug = vim.api.nvim_create_augroup("PuSessionTracking", { clear = true })

vim.api.nvim_create_autocmd("BufAdd", { group = aug, callback = check_unsaved })
vim.api.nvim_create_autocmd("WinNew", { group = aug, callback = check_unsaved })
vim.api.nvim_create_autocmd("TabNew", { group = aug, callback = check_unsaved })

-- Final safety net: if a session is loaded and a debounced autosave
-- is still pending when nvim exits, flush it synchronously so the
-- last few seconds of changes are never lost. Cheap no-op otherwise.
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = aug,
  callback = function()
    if M.current_session and _G.PuSessionUnsaved then
      stop_autosave_timer()
      do_autosave()
    end
  end,
})

-- Keymaps
vim.keymap.set("n", "<leader>sf", M.session_find, { desc = "Session: find/load" })
vim.keymap.set("n", "<leader>sc", M.session_create, { desc = "Session: create" })
vim.keymap.set("n", "<leader>sd", M.session_delete, { desc = "Session: delete (ctrl-x)" })
vim.keymap.set("n", "<leader>ss", M.session_save, { desc = "Session: force immediate save" })

return M
