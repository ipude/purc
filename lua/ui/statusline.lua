-- statusline.lua

_G.lsp_status = function()
  local status = vim.diagnostic.status(0)  -- 0.12 built-in: returns formatted diagnostic string
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return "" end

  local names = vim.iter(clients):map(function(c) return c.name end):totable()
  local label = "󰒋 " .. table.concat(names, ", ")

  if status ~= "" then
    label = label .. " " .. status
  end

  return label
end

_G.sl_filepath = function()
  local name = vim.fn.expand("%:t")
  if name == "" then return "󰈔 [No Name]" end
  return "󰈔 " .. name
end

vim.opt.statusline = " %{%v:lua.sl_filepath()%} %m%r%=%{%v:lua.lsp_status()%}  %l,%c  󰉸 %P "
