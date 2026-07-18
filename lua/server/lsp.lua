vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    local function get_hover_win()
      for _, winid in ipairs(vim.api.nvim_list_wins()) do
        local cfg = vim.api.nvim_win_get_config(winid)
        if cfg.relative ~= "" then
          local buf = vim.api.nvim_win_get_buf(winid)
          if vim.bo[buf].filetype == "markdown" and vim.bo[buf].buftype == "nofile" then
            return winid
          end
        end
      end
      return nil
    end

    local function scroll_hover(dir)
      local winid = get_hover_win()
      if not winid then
        return false
      end
      vim.api.nvim_win_call(winid, function()
        vim.cmd(dir == "down" and "normal! \x06" or "normal! \x02")
      end)
      return true
    end

    vim.keymap.set("n", "<C-f>", function()
      if not scroll_hover("down") then
        vim.cmd("normal! \x06")
      end
    end)
    vim.keymap.set("n", "<C-b>", function()
      if not scroll_hover("up") then
        vim.cmd("normal! \x02")
      end
    end)
  end,
})

vim.keymap.set("n", "<leader>ui", function()
  local buf = vim.api.nvim_get_current_buf()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
end, { desc = "Toggle Inlay Hints" })
