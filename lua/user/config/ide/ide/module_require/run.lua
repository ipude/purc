local M = {}

local runners = {
  go         = function(f) return "go run " .. f end,
  python     = function(f) return "python3 " .. f end,
  javascript = function(f) return "node " .. f end,
  typescript = function(f) return "npx ts-node " .. f end,
  rust       = function(f)
    local root = vim.fn.findfile("Cargo.toml", vim.fn.expand("%:p:h") .. ";")
    if root ~= "" then
      return "cd " .. vim.fn.fnamemodify(root, ":h") .. " && cargo run"
    end
    return "rustc " .. f .. " -o /tmp/__rs_out && /tmp/__rs_out"
  end,
  c          = function(f)
    local out = vim.fn.fnamemodify(f, ":r")
    return "gcc " .. f .. " -o " .. out .. " && " .. out
  end,
  cpp        = function(f)
    local out = vim.fn.fnamemodify(f, ":r")
    return "g++ " .. f .. " -o " .. out .. " && " .. out
  end,
  lua        = function(f) return "lua " .. f end,
  sh         = function(f) return "bash " .. f end,
  bash       = function(f) return "bash " .. f end,
  ruby       = function(f) return "ruby " .. f end,
  php        = function(f) return "php " .. f end,
  zig        = function(f) return "zig run " .. f end,
  dart       = function(f) return "dart run " .. f end,
}

local term_obj = nil

local function get_or_create_term()
  if not term_obj then
    local Terminal = require("toggleterm.terminal").Terminal
    term_obj = Terminal:new({
      direction     = "horizontal",
      close_on_exit = false,
      auto_scroll   = true,
      hidden        = true,
    })
  end
  return term_obj
end

function M.run_file()
  local ft   = vim.bo.filetype
  local file = vim.fn.expand("%:p")

  if file == "" then
    vim.notify("[runner] No file loaded", vim.log.levels.WARN)
    return
  end

  local runner = runners[ft]
  if not runner then
    vim.notify("[runner] No runner for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  vim.cmd("silent! write")

  local ok, term = pcall(get_or_create_term)
  if not ok then
    vim.notify("[runner] toggleterm not found", vim.log.levels.ERROR)
    return
  end

  if not term:is_open() then
    term:open()
  end

  term:send(runners[ft](file), true)
end

function M.toggle()
  local ok, term = pcall(get_or_create_term)
  if not ok then
    vim.notify("[runner] toggleterm not found", vim.log.levels.ERROR)
    return
  end
  term:toggle()
end

vim.keymap.set("n", "<leader>zz", M.run_file, { desc = "[runner] Run current file",      silent = true, noremap = true })
vim.keymap.set("n", "<leader>zx", M.toggle,   { desc = "[runner] Toggle runner terminal", silent = true, noremap = true })

return M
