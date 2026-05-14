local function termux_paste(callback)
  local result = {}
  vim.fn.jobstart({ "termux-clipboard-get" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      result = data
    end,
    on_exit = function()
      local text = table.concat(result, "\n"):gsub("\n$", "")
      callback(text)
    end,
  })
end
--
-- <Leader>pc — Paste from Termux clipboard
vim.keymap.set("n", "<leader>pc", function()
  termux_paste(function(text)
    if text and text ~= "" then
      if text:find("\n") then
        vim.api.nvim_put(vim.split(text, "\n", { plain = true }), "c", true, true)
      else
        vim.api.nvim_put({ text }, "c", true, true)
      end
      vim.notify("Pasted!", vim.log.levels.INFO)
    else
      vim.notify("Clipboard is empty", vim.log.levels.WARN)
    end
  end)
end, { desc = "Paste from Termux clipboard" })
