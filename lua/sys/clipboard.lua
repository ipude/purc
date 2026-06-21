-- ================================================
-- Clipboard (fallback for termux)
-- ================================================
local is_termux = os.getenv("TERMUX_VERSION") ~= nil

local function smart_copy_lines(lines)
  local text = table.concat(lines, "\n")
  local text_size = #text

  if is_termux then
    if text_size > 800000 then
      local size_mb = string.format("%.2f", text_size / 1024 / 1024)
      vim.notify(
        "Yanked " .. size_mb .. "MB. Too large for Android clipboard. Kept inside Neovim.",
        vim.log.levels.WARN
      )
      return
    elseif text_size > 6000 then
      vim.fn.system("termux-clipboard-set", text)
    else
      require("vim.ui.clipboard.osc52").copy("+")(lines)
    end
  else
    require("vim.ui.clipboard.osc52").copy("+")(lines)
  end
end

local function smart_copy_register(reg)
  local lines = vim.fn.getreg(reg, 1, 1)
  smart_copy_lines(lines)
end

-- Normal mode: copy default yank register
vim.keymap.set("n", "<leader>yc", function()
  smart_copy_register('"')
end, { desc = "Copy yank register to system clipboard" })

-- Visual mode: yank selection into temp register, then copy it
vim.keymap.set("v", "<leader>yc", function()
  vim.cmd('normal! "zy')
  local lines = vim.fn.getreg("z", 1, 1)
  if not lines or #lines == 0 or (#lines == 1 and lines[1] == "") then
    vim.notify("Empty selection", vim.log.levels.WARN)
    return
  end
  smart_copy_lines(lines)
end, { desc = "Copy visual selection to system clipboard" })

-- Normal mode: operator-pending — yank with motion into register v
vim.keymap.set("n", "<leader>ym", function()
  -- set operatorfunc then invoke it with g@
  vim.o.operatorfunc = "v:lua.require'your_module'.copy_motion_operatorfunc"
  vim.api.nvim_feedkeys("g@", "n", false)
end, { desc = "Copy motion to system clipboard" })

-- The operatorfunc for motion yank (put this in a module or global)
_G._clipboard_motion_copy = function(motion_type)
  local regs = { line = "'[V']", char = "`[v`]", block = "`[\022`]" }
  local sel = regs[motion_type]
  if not sel then return end
  vim.cmd('normal! ' .. sel .. '"vy')
  smart_copy_register("v")
end

vim.keymap.set("n", "<leader>ym", function()
  vim.o.operatorfunc = "v:lua._clipboard_motion_copy"
  vim.api.nvim_feedkeys("g@", "n", false)
end, { desc = "Copy motion to system clipboard" })

-- Desktop: use system clipboard natively
if not is_termux then
  vim.opt.clipboard = "unnamedplus"
end


