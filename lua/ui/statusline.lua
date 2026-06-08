_G.lsp_status = function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then return "" end

    local names = {}
    for _, c in ipairs(clients) do
        table.insert(names, c.name)
    end

    local e = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    local w = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    local h = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    local i = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })

    local diag = ""
    if e > 0 then diag = diag .. " %#DiagnosticError#󰅚 " .. e .. "%*" end
    if w > 0 then diag = diag .. " %#DiagnosticWarn#󰀪 " .. w .. "%*" end
    if h > 0 then diag = diag .. " %#DiagnosticHint#󰌶 " .. h .. "%*" end
    if i > 0 then diag = diag .. " %#DiagnosticInfo# " .. i .. "%*" end

    return "%#Comment#󰒋 " .. table.concat(names, ", ") .. "%*" .. diag
end

_G.sl_filepath = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local path = vim.fn.expand("%:p")

    if bufname:match("^oil://") then
        local dir = bufname:gsub("^oil://", ""):gsub("^" .. (os.getenv("HOME") or ""), "~")
        return "󰉋 " .. dir
    end
    if bufname:match("^term://") then return "󰆍 terminal" end
    if path == "" then return "󰈔 [No Name]" end

    local home = os.getenv("HOME") or ""
    path = path:gsub("^" .. home .. "/.config", "󱁿 config")
             :gsub("^" .. home .. "/.local/share", "󰉉 data")
             :gsub("^" .. home, "~")

    -- Only shorten intermediate dirs if path is long
    if #path > 40 then
        local head, rest = path:match("^([^/]+)(/.+)$")
        if head and rest then
            local dirs, file = rest:match("^(.*)/([^/]+)$")
            if dirs and dirs ~= "" then
                path = head .. dirs:gsub("/([^/][^/]?)[^/]*", "/%1") .. "/" .. file
            end
        end
    end

    local icon =  "󰈔"

    return icon .. " " .. path
end

vim.opt.statusline = table.concat({
    " %{%v:lua.sl_filepath()%}",
    " %#DiagnosticWarn#%m%r%*",
    "%=",
    "%{%v:lua.lsp_status()%}",
    "  %#Comment#%l,%c  󰉸 %P %*",
})
