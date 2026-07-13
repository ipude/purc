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

-- ============================
-- Shorten a path using whatever env var best matches it
-- ============================
local function shorten_path(p)
  local best_var, best_val
  for k, v in pairs(vim.fn.environ()) do
    if
      type(v) == "string"
      and v:sub(1, 1) == "/"
      and #v > 1
      and p:sub(1, #v) == v
      and (#p == #v or p:sub(#v + 1, #v + 1) == "/")
    then
      if not best_val or #v > #best_val then
        best_var, best_val = k, v
      end
    end
  end
  if not best_var then
    return p
  end
  if best_var == "HOME" then
    return "~" .. p:sub(#best_val + 1)
  end
  return "$" .. best_var .. p:sub(#best_val + 1)
end

map("n", "<leader>ff", function()
  require("fzf-lua").fzf_exec("fd --type d --hidden --exclude .git . " .. vim.fn.shellescape(home()), {
    prompt = "Dir> ",
    actions = {
      ["default"] = function(selected)
        open_files(selected[1], "Files (" .. shorten_path(selected[1]) .. ")> ")
      end,
    },
  })
end, { desc = "Files: pick custom dir (fuzzy)" })
