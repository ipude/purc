-- ============================
-- Termux detection
-- ============================
local _home, _root
local function sys_home()
  if _home then
    return _home
  end
  _home = vim.env.TERMUX_VERSION and "/data/data/com.termux/files/home" or vim.env.HOME or vim.fn.getcwd()
  return _home
end
local function sys_root()
  if _root then
    return _root
  end
  _root = vim.env.TERMUX_VERSION and "/data/data/com.termux/files" or "/"
  return _root
end

-- ============================
-- Helper to escape arguments for FzfLua command
-- ============================
local function escape_cmd_arg(arg)
  if not arg then
    return ""
  end
  -- Escape spaces and special characters
  return arg:gsub(" ", "\\ ")
end

-- ============================
-- Keymaps (all using vim.cmd, truly lazy)
-- ============================
local map = vim.keymap.set

-- Simple commands
map("n", "<leader>fz", "<cmd>FzfLua<cr>", { desc = "FzfLua" })
map("n", "<leader>fd", "<cmd>FzfLua files<cr>", { desc = "Find files CWD" })
map("n", "<leader>fo", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent files" })
map("n", "<leader>gd", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep CWD" })

-- Commands with custom arguments
map("n", "<leader>fc", function()
  local config_dir = vim.fn.expand("$MYVIMRC"):match("(.*/)")
  if config_dir then
    vim.cmd("FzfLua files cwd=" .. escape_cmd_arg(config_dir) .. " prompt='< Neovim Config > '")
  else
    vim.notify("Could not find config directory", vim.log.levels.ERROR)
  end
end, { desc = "Find config files" })

map("n", "<leader>fih", function()
  vim.cmd("FzfLua files cwd=" .. escape_cmd_arg(sys_home()))
end, { desc = "Find Files in HOME" })

map("n", "<leader>fir", function()
  vim.cmd("FzfLua files cwd=" .. escape_cmd_arg(sys_root()))
end, { desc = "Find Files in ROOT" })

map("n", "<leader>gc", function()
  vim.cmd("FzfLua live_grep cwd=" .. escape_cmd_arg(vim.fn.stdpath("config")) .. " prompt='GrepConfig: '")
end, { desc = "Grep config" })

map("n", "<leader>gih", function()
  vim.cmd("FzfLua live_grep cwd=" .. escape_cmd_arg(sys_home()) .. " prompt='GrepHome/'")
end, { desc = "Grep home" })

map("n", "<leader>gir", function()
  vim.cmd("FzfLua live_grep cwd=" .. escape_cmd_arg(sys_root()) .. " prompt='GrepRoot/'")
end, { desc = "Grep root" })

-- Custom directory functions
local function fzf_in_custom_dir(mode)
  mode = mode or "files"
  vim.ui.input({
    prompt = " Dir: ",
    default = vim.fn.getcwd(),
    completion = "dir",
  }, function(input)
    if not input or input == "" then
      return
    end
    local path = vim.fn.expand(input)
    path = path:gsub("%$(%w+)", function(var)
      return os.getenv(var) or ("$" .. var)
    end)
    if vim.fn.isdirectory(path) == 0 then
      vim.notify("Not a directory: " .. path, vim.log.levels.ERROR)
      return
    end

    -- Use FzfLua command instead of requiring the module
    local cmd = "FzfLua " .. mode .. " cwd=" .. escape_cmd_arg(path)
    vim.cmd(cmd)
  end)
end

-- usage : `touch .root` at root of project (once per project)
vim.keymap.set("n", "<leader>ff", function()
  local root = vim.fs.root(0, {".root"})
  require("fzf-lua").files({ cwd = root })
end, { desc = "Open root" })

map("n", "<leader>ef", function()
  fzf_in_custom_dir("files")
end, { desc = "Open custom dir" })

map("n", "<leader>eg", function()
  fzf_in_custom_dir("grep")
end, { desc = "Grep in custom dir" })
