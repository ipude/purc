-- ~/.config/nvim/lua/user/session.lua
--
-- Custom session manager built directly on Neovim's native
-- :mksession / :source API (no session plugin), with fzf-lua pickers.
--
-- Keymaps:
--   <leader>sf  Session Find   -> fuzzy pick + (re)load a session fresh
--   <leader>sc  Session Create -> new session, fails if name already exists
--   <leader>sd  Session Delete -> persistent fzf multi-delete (ctrl-x)
--   <leader>ss  Session Save   -> explicit write to the active session
--
-- Requires: fzf-lua (https://github.com/ibhagwan/fzf-lua)
--
-- Global state (exposed for use from other config files):
--   _G.PuSessionLoaded   -> false, or the loaded session's name (string)
--   _G.PuSessionUnsaved  -> true once a NEW buffer/split/tab has been
--                           added since the session was last loaded/saved
--   _G.PuSessionSnapshot -> internal baseline snapshot (buffers/splits/
--                           tabs) taken at load/save time; exposed
--                           mainly for debugging/inspection

local M = {}
local uv = vim.loop
local fzf = require("fzf-lua")

-- All sessions live here, one file per session, named by the user.
M.session_dir = vim.fn.stdpath("data") .. "/PuSession/"

-- Tracks the name of whatever session is currently "active" in this
-- editor instance (set on create/load). <leader>ss writes to this.
M.current_session = nil

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
-- snapshot, and clears the unsaved flag.
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

-- Invoked from BufAdd/WinNew/TabNew only. No-ops if no session is
-- currently loaded, or if the flag is already set.
local function check_unsaved()
  if not _G.PuSessionLoaded or _G.PuSessionUnsaved then
    return
  end
  if has_new_entities(_G.PuSessionSnapshot) then
    _G.PuSessionUnsaved = true
  end
end

--- Returns the loaded session's name (truthy string) if a session is
--- currently loaded, or `false` otherwise.
function M.is_session_loaded()
  return _G.PuSessionLoaded
end

--- Returns true if new buffers/splits/tabs have been added since the
--- active session was last loaded/saved.
function M.is_unsaved()
  return _G.PuSessionUnsaved
end

--- <leader>ss — Session Save
-- Writes current editor state to the currently active session file.
-- If nothing is active yet (fresh nvim, never created/loaded one),
-- prompts for a name so save never silently no-ops.
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

  vim.cmd("mksession! " .. vim.fn.fnameescape(session_path(M.current_session)))
  mark_loaded(M.current_session)
  vim.notify("Session saved: " .. M.current_session)
end

--- <leader>sc — Session Create
-- Name must be unique; refuses (does not overwrite) if it exists.
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
    vim.notify("Session created: " .. name)
  end)
end

--- <leader>sf — Session Find / Load
-- Fuzzy-pick a session from PuSession/ and load it fresh (reset first).
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
        vim.notify("Loaded session: " .. name)
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
-- what keeps the "unsaved" check from ever tripping on plain
-- navigation.
-- ---------------------------------------------------------------------
local aug = vim.api.nvim_create_augroup("PuSessionTracking", { clear = true })

vim.api.nvim_create_autocmd("BufAdd", { group = aug, callback = check_unsaved })
vim.api.nvim_create_autocmd("WinNew", { group = aug, callback = check_unsaved })
vim.api.nvim_create_autocmd("TabNew", { group = aug, callback = check_unsaved })

-- ---------------------------------------------------------------------
-- Quit guard: if a session is loaded and has unsaved buffers/splits/
-- tabs, pop up a native confirm() dialog on the way out and let the
-- user bail. Autocmds (QuitPre/VimLeavePre) can't actually abort a
-- quit in Neovim, so this works by intercepting the ex commands
-- themselves — user commands for the canonical spellings, plus
-- cmdline abbreviations so typing the normal `:q`, `:qa`, etc. gets
-- silently redirected to the guarded version. ZZ/ZQ are remapped too.
-- ---------------------------------------------------------------------

local function has_unsaved_session()
  return _G.PuSessionLoaded ~= false and _G.PuSessionUnsaved == true
end

-- Returns true if it's OK to proceed with quitting.
local function confirm_quit()
  if not has_unsaved_session() then
    return true
  end

  local choice = vim.fn.confirm(
    "Session '"
      .. _G.PuSessionLoaded
      .. "' has unsaved changes "
      .. "(new buffer/split/tab).\nQuit anyway and lose them?",
    "&Yes, quit\n&No, cancel",
    2 -- default focus on "No"
  )

  if choice ~= 1 then
    vim.notify("Quit cancelled — session not saved", vim.log.levels.WARN)
    return false
  end
  return true
end

-- Wraps a real quit command with the guard. `bang_cmd`/`nobang_cmd` are
-- the actual ex commands to run once confirmed (or immediately, if
-- nothing is unsaved).
local function guarded(bang_cmd, nobang_cmd)
  return function(opts)
    if not confirm_quit() then
      return
    end
    vim.cmd(opts.bang and bang_cmd or nobang_cmd)
  end
end

vim.api.nvim_create_user_command("Q", guarded("q!", "q"), { bang = true })
vim.api.nvim_create_user_command("Qa", guarded("qa!", "qa"), { bang = true })
vim.api.nvim_create_user_command("Qall", guarded("qall!", "qall"), { bang = true })
vim.api.nvim_create_user_command("Wq", guarded("wq!", "wq"), { bang = true })
vim.api.nvim_create_user_command("Wqa", guarded("wqa!", "wqa"), { bang = true })
vim.api.nvim_create_user_command("Xa", guarded("xa!", "xa"), { bang = true })

-- Redirect the built-in lowercase spellings to the guarded commands
-- above, but ONLY when they're the whole command line (so e.g. `:qa!`
-- as literally typed still passes through untouched at the character
-- level — cnoreabbrev only fires on the bare word).
local function guard_abbrev(bare)
  local target = bare:sub(1, 1):upper() .. bare:sub(2)
  vim.cmd(
    string.format(
      [[cnoreabbrev <expr> %s (getcmdtype() == ':' && getcmdline() == '%s') ? '%s' : '%s']],
      bare,
      bare,
      target,
      bare
    )
  )
end

for _, cmd in ipairs({ "q", "qa", "qall", "wq", "wqa", "xa" }) do
  guard_abbrev(cmd)
end

-- Normal-mode quit shortcuts, made session-aware too.
vim.keymap.set("n", "ZZ", function()
  if not confirm_quit() then
    return
  end
  vim.cmd("wqa")
end, { desc = "Session-aware ZZ (write & quit all)" })

vim.keymap.set("n", "ZQ", function()
  if not confirm_quit() then
    return
  end
  vim.cmd("qa!")
end, { desc = "Session-aware ZQ (quit all, discard)" })

-- Keymaps
vim.keymap.set("n", "<leader>sf", M.session_find, { desc = "Session: find/load" })
vim.keymap.set("n", "<leader>sc", M.session_create, { desc = "Session: create" })
vim.keymap.set("n", "<leader>sd", M.session_delete, { desc = "Session: delete (ctrl-x)" })
vim.keymap.set("n", "<leader>ss", M.session_save, { desc = "Session: save" })

return M
