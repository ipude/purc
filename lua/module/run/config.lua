local M = {}

local runners = {
  go = function(f)
    return "go run " .. f
  end,
  python = function(f)
    return "python3 " .. f
  end,
  javascript = function(f)
    return "node " .. f
  end,
  typescript = function(f)
    return "npx ts-node " .. f
  end,
  rust = function(f)
    local root = vim.fn.findfile("Cargo.toml", vim.fn.expand("%:p:h") .. ";")
    if root ~= "" then
      return "cd " .. vim.fn.fnamemodify(root, ":h") .. " && cargo run"
    end
    return "rustc " .. f .. " -o /tmp/__rs_out && /tmp/__rs_out"
  end,
  c = function(f)
    local out = vim.fn.fnamemodify(f, ":r")
    return "gcc " .. f .. " -o " .. out .. " && " .. out
  end,
  cpp = function(f)
    local out = vim.fn.fnamemodify(f, ":r")
    return "g++ " .. f .. " -o " .. out .. " && " .. out
  end,
  lua = function(f)
    return "lua " .. f
  end,
  sh = function(f)
    return "bash " .. f
  end,
  bash = function(f)
    return "bash " .. f
  end,
  ruby = function(f)
    return "ruby " .. f
  end,
  php = function(f)
    return "php " .. f
  end,
  zig = function(f)
    return "zig run " .. f
  end,
  dart = function(f)
    return "dart run " .. f
  end,
}

local term_buf = nil

local function is_valid_term()
  return term_buf ~= nil and vim.api.nvim_buf_is_valid(term_buf) and vim.bo[term_buf].buftype == "terminal"
end

function M.run_file()
  local ft = vim.bo.filetype
  local raw_file = vim.fn.expand("%:p")
  local file = type(raw_file) == "string" and raw_file or tostring(raw_file)

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

  local cmd = runner(file)

  if not is_valid_term() then
    vim.cmd("terminal")
    term_buf = vim.api.nvim_get_current_buf()
    vim.defer_fn(function()
      vim.api.nvim_chan_send(vim.b[term_buf].terminal_job_id, cmd .. "\n")
    end, 80)
  else
    vim.cmd("buffer " .. term_buf)
    vim.api.nvim_chan_send(vim.b[term_buf].terminal_job_id, cmd .. "\n")
  end
end

function M.toggle()
  if not is_valid_term() then
    vim.cmd("terminal")
    term_buf = vim.api.nvim_get_current_buf()
    return
  end

  -- If currently viewing the terminal, go back
  if vim.api.nvim_get_current_buf() == term_buf then
    vim.cmd("bprevious")
  else
    vim.cmd("buffer " .. term_buf)
    vim.cmd("startinsert")
  end
end

vim.keymap.set("n", "<leader>zz", M.run_file, { desc = "[runner] Run current file", silent = true, noremap = true })
vim.keymap.set("n", "<leader>zx", M.toggle, { desc = "[runner] Toggle runner terminal", silent = true, noremap = true })

return M
