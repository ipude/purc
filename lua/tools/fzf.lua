local setup_done = false
local function fzf()
  if not setup_done then
    setup_done = true
    require("fzf-lua").setup({
      winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,
        border = "rounded",
        preview = {
          border = "rounded",
          wrap = "nowrap",
          hidden = "nohidden",
          vertical = "down:45%",
          horizontal = "right:60%",
          layout = "flex",
          flip_columns = 120,
        },
      },
      fzf_colors = {
        ["fg"] = { "fg", "Normal" },
        ["bg"] = { "bg", "Normal" },
        ["fg+"] = { "fg", "Normal" },
        ["bg+"] = { "bg", "Visual" },
        ["hl"] = { "fg", "Identifier" },
        ["hl+"] = { "fg", "Statement" },
        ["prompt"] = { "fg", "Keyword" },
        ["pointer"] = { "fg", "Type" },
        ["marker"] = { "fg", "Type" },
        ["header"] = { "fg", "Title" },
        ["info"] = { "fg", "Special" },
      },
      files = {
        prompt = " ",
        multiprocess = true,
        git_icons = true,
        file_icons = true,
        color_icons = true,
        fd_opts = "--color=never --type f --hidden --follow --exclude .git",
      },
      grep = {
        prompt = " ",
        input_prompt = "Grep  ",
        multiprocess = true,
        git_icons = true,
        file_icons = true,
        color_icons = true,
        rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case -g '!.git'",
      },
    })

    vim.ui.select = function(items, opts, on_choice)
      require("fzf-lua").fzf_exec(items, {
        prompt = (opts and opts.prompt) or "Select: ",
        fzf_opts = { ["--no-multi"] = true },
        actions = {
          ["default"] = function(selected)
            if not selected or #selected == 0 then
              on_choice(nil, nil)
              return
            end
            local display = selected[1]
            for i, item in ipairs(items) do
              local label = opts and opts.format_item and opts.format_item(item) or tostring(item)
              if label == display then
                on_choice(item, i)
                return
              end
            end
            on_choice(nil, nil)
          end,
        },
      })
    end

    vim.ui.input = function(opts, on_confirm)
      local prompt = opts.prompt or "Input: "
      local default = opts.default or ""

      local buf = vim.api.nvim_create_buf(false, true)
      local width = math.max(40, #prompt + #default + 10)
      local win = vim.api.nvim_open_win(buf, true, {
        relative = "cursor",
        row = 1,
        col = 0,
        width = width,
        height = 1,
        style = "minimal",
        border = "rounded",
        title = " " .. prompt .. " ",
        title_pos = "left",
      })

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { default })
      vim.cmd("startinsert!")
      if #default > 0 then
        vim.api.nvim_win_set_cursor(win, { 1, #default })
      end

      local function close(confirm)
        local value = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
        vim.api.nvim_win_close(win, true)
        vim.cmd("stopinsert")
        if confirm then
          on_confirm(value ~= "" and value or nil)
        else
          on_confirm(nil)
        end
      end

      local map_opts = { buffer = buf, nowait = true }
      vim.keymap.set("i", "<CR>", function()
        close(true)
      end, map_opts)
      vim.keymap.set("i", "<C-c>", function()
        close(false)
      end, map_opts)
      vim.keymap.set("n", "<Esc>", function()
        close(false)
      end, map_opts)
      vim.keymap.set("n", "<CR>", function()
        close(true)
      end, map_opts)
    end
  end
  return require("fzf-lua")
end

-- ============================
-- Bootstrap vim.ui overrides
-- ============================
do
  local _select = vim.ui.select
  vim.ui.select = function(...)
    local args = { ... }
    fzf()
    if vim.ui.select ~= _select then
      vim.ui.select(unpack(args))
    else
      _select(unpack(args))
    end
  end

  local _input = vim.ui.input
  vim.ui.input = function(opts, on_confirm)
    fzf()
    if vim.ui.input ~= _input then
      vim.ui.input(opts, on_confirm)
    else
      _input(opts, on_confirm)
    end
  end
end

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
-- Keymaps
-- ============================
local k = vim.keymap.set
k("n", "<leader>fz", function()
  fzf().setup_called = true
  vim.cmd("FzfLua")
end, { desc = "FzfLua" })
k("n", "<leader>fd", function()
  fzf().files()
end, { desc = "Find files CWD" })
k("n", "<leader>fo", function()
  fzf().oldfiles()
end, { desc = "Recent files" })
k("n", "<leader>fc", function()
  fzf().files({ cwd = vim.fn.expand("$MYVIMRC"):match("(.*/)"), prompt = "< Neovim Config > " })
end, { desc = "Find config files" })
k("n", "<leader>fih", function()
  fzf().files({ cwd = sys_home() })
end, { desc = "Find Files in HOME" })
k("n", "<leader>fir", function()
  fzf().files({ cwd = sys_root() })
end, { desc = "Find Files in ROOT" })
k("n", "<leader>dw", function()
  fzf().diagnostics_workspace()
end, { desc = "Workspace diagnostics" })
k("n", "<leader>gd", function()
  fzf().live_grep({ prompt = "GrepCwd: " })
end, { desc = "Live grep CWD" })
k("n", "<leader>gc", function()
  fzf().live_grep({ cwd = vim.fn.stdpath("config"), prompt = "GrepConfig: " })
end, { desc = "Grep config" })
k("n", "<leader>gih", function()
  fzf().live_grep({ cwd = sys_home(), prompt = "GrepHome/" })
end, { desc = "Grep home" })
k("n", "<leader>gir", function()
  fzf().live_grep({ cwd = sys_root(), prompt = "GrepRoot/" })
end, { desc = "Grep root" })

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
    if mode == "files" then
      fzf().files({ cwd = path })
    elseif mode == "grep" then
      fzf().live_grep({ cwd = path })
    end
  end)
end

k("n", "<leader>ef", function()
  fzf_in_custom_dir("files")
end, { desc = "FZF files in typed dir" })
k("n", "<leader>eg", function()
  fzf_in_custom_dir("grep")
end, { desc = "FZF grep in typed dir" })
