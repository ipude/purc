vim.o.showcmdloc = "statusline"
vim.o.cmdheight = 1

local function lsp_clients()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then return "" end
    local names = {}
    for _, c in ipairs(clients) do
        table.insert(names, c.name)
    end
    return " [" .. table.concat(names, ", ") .. "]"
end

local function diagnostics()
    local d = vim.diagnostic.get(0)
    local counts = { 0, 0, 0, 0 } -- E W I H
    for _, item in ipairs(d) do
        counts[item.severity] = counts[item.severity] + 1
    end

    local parts = {}
    if counts[1] > 0 then table.insert(parts, "[E:" .. counts[1] .. ']') end
    if counts[2] > 0 then table.insert(parts, "[W:" .. counts[2] .. ']') end
    if counts[3] > 0 then table.insert(parts, "[I:" .. counts[3] .. ']') end
    if counts[4] > 0 then table.insert(parts, "[H:" .. counts[4] .. ']') end

    if #parts == 0 then return "" end
    return " " .. table.concat(parts, " ")
end

vim.o.statusline = "%!v:lua.Statusline()"

function _G.Statusline()
    local path     = "%F"
    local modified = "%m"
    local readonly = "%r"
    local sep      = "%="
    local showcmd  = "%S"
    local coords   = "%l,%c"
    local percent  = "%p%%"
    local lsp      = lsp_clients()
    local diag     = diagnostics()

    return path ..
    modified .. readonly .. sep .. showcmd .. " " .. diag .. " " .. lsp .. "  " .. coords .. "  " .. percent .. " "
end
