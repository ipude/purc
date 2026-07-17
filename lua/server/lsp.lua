vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    local opts = { buffer = ev.buf, silent = true }

    local function hover_in_split()
      local params = vim.lsp.util.make_position_params(0, "utf-8")

      vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result, ctx)
        if err or not result or not result.contents then
          vim.notify("No hover info", vim.log.levels.INFO)
          return
        end

        -- Convert whatever the server sent (string / MarkupContent / marked_string[])
        -- into plain markdown lines, same util the built-in float uses.
        local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
        if vim.tbl_isempty(lines) then
          vim.notify("No hover info", vim.log.levels.INFO)
          return
        end

        -- Open a temporary split at the top, sized to fit content (capped).
        vim.cmd("topleft " .. math.min(#lines + 1, 20) .. "split")
        local buf = vim.api.nvim_create_buf(false, true) -- unlisted, scratch
        vim.api.nvim_win_set_buf(0, buf)

        vim.bo[buf].filetype = "markdown"
        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].swapfile = false
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false

        -- Quick, familiar ways to dismiss it.
        local close_opts = { buffer = buf, nowait = true, silent = true }
        vim.keymap.set("n", "q", "<cmd>close<CR>", close_opts)
        vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", close_opts)

        -- Auto-close the moment you leave it, so it never lingers as a
        -- stray split you have to manually clean up.
        vim.api.nvim_create_autocmd("WinLeave", {
          buffer = buf,
          once = true,
          callback = function()
            if vim.api.nvim_buf_is_valid(buf) then
              pcall(vim.api.nvim_win_close, 0, true)
            end
          end,
        })
      end)
    end

    vim.keymap.set("n", "K", hover_in_split, opts)

    vim.keymap.set("i", "<C-h>", function()
      vim.lsp.buf.signature_help()
    end, opts)
  end,
})

vim.keymap.set("n", "<leader>ui", function()
  local buf = vim.api.nvim_get_current_buf()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
end, { desc = "Toggle Inlay Hints" })
