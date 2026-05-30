_G.lsp_status = function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then return "" end

    local names = {}
    for _, c in ipairs(clients) do table.insert(names, c.name) end

    local e = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    local w = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    local h = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    local i = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })

    local diag = ""
    if e > 0 then diag = diag .. "%#DiagnosticError# [E:" .. e .. "]%*" end
    if w > 0 then diag = diag .. "%#DiagnosticWarn# [W:" .. w .. "]%*" end
    if h > 0 then diag = diag .. "%#DiagnosticHint# [H:" .. h .. "]%*" end
    if i > 0 then diag = diag .. "%#DiagnosticInfo# [I:" .. i .. "]%*" end

    return " [" .. table.concat(names, ",") .. "]" .. diag
end

vim.opt.statusline = "%f %h%m%r%=%{%v:lua.lsp_status()%}  %-14.(%l,%c%V%) %P"
