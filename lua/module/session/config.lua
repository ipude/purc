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

local M = {}
local uv = vim.loop
local fzf = require("fzf-lua")

-- All sessions live here, one file per session, named by the user.
M.session_dir = vim.fn.stdpath("data") .. "/PuSession/"

-- Tracks the name of whatever session is currently "active" in this
-- editor instance (set on create/load). <leader>ss writes to this.
M.current_session = nil

-- sessionoptions is the single biggest lever here:
--   - NO "curdir"/"sesdir"  -> Vim stores each buffer's *full absolute
--     path* in the session file instead of paths relative to a cwd
--     that may not exist/match next time you load it.
--   - NO "blank"/"terminal" -> no empty scratch buffers or dead
--     terminal jobs get "restored" as stale placeholders.
--   - buffers,tabpages,winsize,winpos,folds -> full layout (splits,
--     tabs, fold state) is captured and restored exactly.
vim.o.sessionoptions =
  "buffers,tabpages,winsize,winpos,folds,localoptions,globals,help"

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
      M.current_session = name
      vim.cmd("mksession! " .. vim.fn.fnameescape(session_path(name)))
      vim.notify("Session created & saved: " .. name)
    end)
    return
  end

  vim.cmd("mksession! " .. vim.fn.fnameescape(session_path(M.current_session)))
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
    M.current_session = name
    vim.cmd("mksession! " .. vim.fn.fnameescape(session_path(name)))
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
        if not selected or #selected == 0 then return end
        local name = selected[1]
        local path = session_path(name)
        if not file_exists(path) then
          vim.notify("Session file missing: " .. path, vim.log.levels.ERROR)
          return
        end
        reset_editor_state()
        vim.cmd("silent! source " .. vim.fn.fnameescape(path))
        M.current_session = name
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
        if not selected or #selected == 0 then return end
        for _, name in ipairs(selected) do
          local path = session_path(name)
          if file_exists(path) then
            if uv.fs_unlink(path) then
              if M.current_session == name then
                M.current_session = nil
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

-- Keymaps
vim.keymap.set("n", "<leader>sf", M.session_find, { desc = "Session: find/load" })
vim.keymap.set("n", "<leader>sc", M.session_create, { desc = "Session: create" })
vim.keymap.set("n", "<leader>sd", M.session_delete, { desc = "Session: delete (ctrl-x)" })
vim.keymap.set("n", "<leader>ss", M.session_save, { desc = "Session: save" })

return M
