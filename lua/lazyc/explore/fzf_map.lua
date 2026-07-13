-- ============================
-- Path resolvers
-- ============================
local function home()
  return vim.env.TERMUX_VERSION and "/data/data/com.termux/files/home" or vim.env.HOME or vim.fn.getcwd()
end

local function prefix()
  return vim.env.PREFIX or "/"
end

local function root()
  return vim.fs.root(0, { ".root", ".git" }) or vim.fn.getcwd()
end

local function config()
  return vim.fn.stdpath("config")
end

-- ============================
-- files/grep opener with ctrl-g / ctrl-f toggle
-- ============================
local open_files, open_grep

local switching = false
local function guard(fn)
  return function(...)
    if switching then
      return
    end
    switching = true
    local args = { ... }
    vim.schedule(function()
      fn(unpack(args))
      vim.defer_fn(function()
        switching = false
      end, 150)
    end)
  end
end

open_files = function(cwd, label)
  require("fzf-lua").files({
    cwd = cwd,
    prompt = label,
    actions = { ["ctrl-r"] = guard(function()
      open_grep(cwd, label)
    end) },
  })
end

open_grep = function(cwd, label)
  require("fzf-lua").live_grep({
    cwd = cwd,
    prompt = label,
    actions = { ["ctrl-r"] = guard(function()
      open_files(cwd, label)
    end) },
  })
end
-- ============================
-- Keymaps (6 total)
-- ============================
local map = vim.keymap.set

map("n", "<leader>fd", function()
  open_files(vim.fn.getcwd(), "Files (cwd)> ")
end, { desc = "Files: cwd" })
map("n", "<leader>fr", function()
  open_files(root(), "Files (root)> ")
end, { desc = "Files: project root" })
map("n", "<leader>fh", function()
  open_files(home(), "Files ($HOME)> ")
end, { desc = "Files: $HOME" })
map("n", "<leader>fp", function()
  open_files(prefix(), "Files ($PREFIX)> ")
end, { desc = "Files: $PREFIX" })
map("n", "<leader>fc", function()
  open_files(config(), "Files (nvim config)> ")
end, { desc = "Files: nvim config" })

local pick_dir  -- forward declare so open_files/open_grep can reference it

local function termux_roots()
  return {
    HOME = os.getenv("HOME") or "/data/data/com.termux/files/home",
    PREFIX = os.getenv("PREFIX") or "/data/data/com.termux/files/usr",
  }
end

local function expand_label(label)
  local roots = termux_roots()
  if label:sub(1, 1) == "~" then
    return roots.HOME .. label:sub(2)
  elseif label:sub(1, 8) == "$PREFIX/" or label == "$PREFIX" then
    return roots.PREFIX .. label:sub(8)
  end
  return label
end

pick_dir = function()
  local roots = termux_roots()
  local cmd = string.format(
    [[{ fd --type d --hidden --exclude .git . %s 2>/dev/null | sed "s#^%s#~#"; ]]
      .. [[fd --type d --hidden --exclude .git . %s 2>/dev/null | sed "s#^%s#\$PREFIX#"; }]],
    vim.fn.shellescape(roots.HOME), roots.HOME,
    vim.fn.shellescape(roots.PREFIX), roots.PREFIX
  )

  require("fzf-lua").fzf_exec(cmd, {
    prompt = "Dir> ",
    actions = {
      ["default"] = function(selected)
        local full = expand_label(selected[1])
        open_files(full, "Files (" .. selected[1] .. ")> ")
      end,
    },
  })
end

open_files = function(cwd, label)
  require("fzf-lua").files({
    cwd = cwd,
    prompt = label,
    cwd_prompt = false,
    actions = {
      ["ctrl-r"] = guard(function() open_grep(cwd, label) end),
      ["alt-r"] = guard(pick_dir),
    },
  })
end

open_grep = function(cwd, label)
  require("fzf-lua").live_grep({
    cwd = cwd,
    prompt = label,
    cwd_prompt = false,
    actions = {
      ["ctrl-r"] = guard(function() open_files(cwd, label) end),
      ["alt-r"] = guard(pick_dir),
    },
  })
end

map("n", "<leader>ff", pick_dir, { desc = "Files: pick custom dir ($HOME/$PREFIX)" })
