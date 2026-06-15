-- diagnostics_panel.lua
-- ~/.config/nvim/lua/diagnostics_panel.lua
-- require("diagnostics_panel").setup()

local M = {}

local SEV = vim.diagnostic.severity

local SEV_HL = {
    [SEV.ERROR] = "DiagnosticError",
    [SEV.WARN]  = "DiagnosticWarn",
    [SEV.INFO]  = "DiagnosticInfo",
    [SEV.HINT]  = "DiagnosticHint",
}

local SEV_ICON = {
    [SEV.ERROR] = "● ",
    [SEV.WARN]  = "● ",
    [SEV.INFO]  = "● ",
    [SEV.HINT]  = "● ",
}

-- ── highlights ─────────────────────────────────────────────────────────────

local function setup_highlights()
    -- Current-line heading: bright/title weight
    vim.api.nvim_set_hl(0, "DiagPanelCurLine", { link = "Title",    default = true })
    -- Non-current headings: link to Function — picks up theme's accent color
    -- (blue, gold, teal, etc.) so they read as headings, not plain text
    vim.api.nvim_set_hl(0, "DiagPanelHeading", { link = "Function", default = true })
    -- Tree chrome and source tags
    vim.api.nvim_set_hl(0, "DiagPanelMeta",    { link = "Comment",  default = true })
    -- Message body
    vim.api.nvim_set_hl(0, "DiagPanelMsg",     { link = "Normal",   default = true })
    -- Tree connector lines  │ ├ └ ─
    vim.api.nvim_set_hl(0, "DiagPanelTree",    { link = "NonText",  default = true })
end

-- ── statusline ─────────────────────────────────────────────────────────────
--
-- With laststatus=3 the global statusline lives at the very bottom.
-- Each split still has its own per-window statusline drawn at the split
-- boundary — that IS the separator bar.  Setting vim.wo[win].statusline
-- gives us:   ─ Diagnostic Panel ──────────────────────────────────────
-- %#Hl#  = switch highlight group inline
-- %=     = right-fill (pushes nothing; combined with the rule text acts
--          as an infinite right-pad that Neovim clips to window width)

local function panel_statusline()
    return "%#NonText#─%#DiagPanelCurLine# Diagnostic Panel %#NonText#%{"
        .. "repeat('─', winwidth(0) - 20)}"
end

-- ── build lines + extmarks ─────────────────────────────────────────────────
--
-- Tree layout per line-group:
--
--   (virtual heading overlay on blank anchor line)
--   │
--   ├─ 󰅚  Error message   [source]
--   ├─ 󰀪  Warning message
--   └─ 󰋽  Info message
--
-- Between groups: one blank separator line.

local function build(diags, cur_line)
    local by_lnum = {}
    local order   = {}
    for _, d in ipairs(diags) do
        local ln = d.lnum
        if not by_lnum[ln] then
            by_lnum[ln] = {}
            table.insert(order, ln)
        end
        table.insert(by_lnum[ln], d)
    end

    table.sort(order, function(a, b)
        if a == cur_line and b ~= cur_line then return true  end
        if b == cur_line and a ~= cur_line then return false end
        return a < b
    end)

    local lines = {}
    local hls   = {}

    local function hl(row, cs, ce, grp)
        table.insert(hls, { row = row, col_s = cs, col_e = ce, grp = grp })
    end

    if #order == 0 then
        table.insert(lines, "  ✓  no diagnostics")
        hl(0, 0, #"  ✓  no diagnostics", "DiagPanelMeta")
        return lines, hls
    end

    for i, ln in ipairs(order) do
        local is_cur  = (ln == cur_line)
        local hdr_hl  = is_cur and "DiagPanelCurLine" or "DiagPanelHeading"
        local marker  = is_cur and "› " or "■ "
        local lbl     = marker .. "line " .. tostring(ln + 1)

        -- Separator blank between groups
        if i > 1 then
            table.insert(lines, "")
        end

        -- Heading as real buffer text — fully yankable with osc52
        local hrow = #lines
        table.insert(lines, lbl)
        hl(hrow, 0, #lbl, hdr_hl)

        local group = by_lnum[ln]
        local n     = #group

        -- Diagnostic rows with tree connectors
        for j, d in ipairs(group) do
            local is_last  = (j == n)
            local connector = is_last and "└─ " or "├─ "
            local icon      = SEV_ICON[d.severity] or "● "
            local msg       = d.message:gsub("\n", " ")
            local src       = d.source and ("[" .. d.source .. "]") or ""

            -- Build the full line text
            local entry = connector .. icon .. msg .. (src ~= "" and ("  " .. src) or "")
            local erow  = #lines
            table.insert(lines, entry)

            -- connector  ├─  or  └─
            hl(erow, 0, #connector, "DiagPanelTree")

            -- severity icon
            local icon_s = #connector
            local icon_e = icon_s + #icon
            hl(erow, icon_s, icon_e, SEV_HL[d.severity] or "Normal")

            -- message
            local msg_s = icon_e
            local msg_e = msg_s + #msg
            hl(erow, msg_s, msg_e, "DiagPanelMsg")

            -- source tag
            if src ~= "" then
                local src_s = msg_e + 2
                local src_e = src_s + #src
                hl(erow, src_s, src_e, "DiagPanelMeta")
            end
        end
    end

    return lines, hls
end

-- ── panel state ────────────────────────────────────────────────────────────

local ns = vim.api.nvim_create_namespace("diag_panel")
local S  = { bufnr = nil, winid = nil, src_winid = nil, autocmd_id = nil }

local function is_open()
    return S.bufnr and vim.api.nvim_buf_is_valid(S.bufnr)
       and S.winid and vim.api.nvim_win_is_valid(S.winid)
end

local function render(diags, cur_line)
    local lines, hls = build(diags, cur_line)

    vim.bo[S.bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(S.bufnr, 0, -1, false, lines)
    vim.bo[S.bufnr].modifiable = false

    vim.api.nvim_buf_clear_namespace(S.bufnr, ns, 0, -1)

    for _, h in ipairs(hls) do
        vim.api.nvim_buf_add_highlight(S.bufnr, ns, h.grp, h.row, h.col_s, h.col_e)
    end
end

local function refresh()
    if not is_open() then return end
    if not S.src_winid or not vim.api.nvim_win_is_valid(S.src_winid) then return end
    local src_buf  = vim.api.nvim_win_get_buf(S.src_winid)
    local cur_line = vim.api.nvim_win_get_cursor(S.src_winid)[1] - 1
    local diags    = vim.diagnostic.get(src_buf)
    table.sort(diags, function(a, b)
        if a.lnum ~= b.lnum then return a.lnum < b.lnum end
        return a.severity < b.severity
    end)
    render(diags, cur_line)
end

local function close()
    if S.autocmd_id then
        pcall(vim.api.nvim_del_autocmd, S.autocmd_id)
        S.autocmd_id = nil
    end
    if S.winid and vim.api.nvim_win_is_valid(S.winid) then
        vim.api.nvim_win_close(S.winid, true)
    end
    if S.bufnr and vim.api.nvim_buf_is_valid(S.bufnr) then
        vim.api.nvim_buf_delete(S.bufnr, { force = true })
    end
    S.bufnr = nil; S.winid = nil; S.src_winid = nil
end

local function open(height)
    local src_win  = vim.api.nvim_get_current_win()
    local src_buf  = vim.api.nvim_get_current_buf()
    local cur_line = vim.api.nvim_win_get_cursor(src_win)[1] - 1

    S.src_winid = src_win

    local diags = vim.diagnostic.get(src_buf)
    table.sort(diags, function(a, b)
        if a.lnum ~= b.lnum then return a.lnum < b.lnum end
        return a.severity < b.severity
    end)

    S.bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[S.bufnr].buftype   = "nofile"
    vim.bo[S.bufnr].filetype  = "diagnostics_panel"
    vim.bo[S.bufnr].bufhidden = "wipe"
    vim.bo[S.bufnr].swapfile  = false

    render(diags, cur_line)

    vim.cmd("botright " .. height .. "split")
    S.winid = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(S.winid, S.bufnr)

    -- ── per-window statusline ──────────────────────────────────────────────
    -- laststatus=3 draws one global bar at the bottom, but every split still
    -- has its own statusline at the split boundary.  Overriding it here gives
    -- us the  ─ Diagnostic Panel ───  rule without touching winbar at all.
    vim.wo[S.winid].statusline = panel_statusline()

    local wo = vim.wo[S.winid]
    wo.number         = false
    wo.relativenumber = false
    wo.signcolumn     = "no"
    wo.wrap           = false
    wo.cursorline     = false
    wo.foldcolumn     = "0"
    wo.winfixheight   = true

    local km = function(lhs, rhs)
        vim.keymap.set("n", lhs, rhs, { buffer = S.bufnr, silent = true })
    end
    km("q",     close)
    km("<Esc>", close)

    S.autocmd_id = vim.api.nvim_create_autocmd({ "CursorMoved", "DiagnosticChanged" }, {
        buffer   = src_buf,
        callback = refresh,
    })
    vim.api.nvim_create_autocmd("WinClosed", {
        pattern  = tostring(src_win),
        once     = true,
        callback = close,
    })

    vim.api.nvim_set_current_win(src_win)
end

-- ── setup ──────────────────────────────────────────────────────────────────

function M.setup(opts)
    opts = opts or {}
    local height = opts.height or 10

    setup_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_highlights })

    vim.keymap.set("n", opts.keymap or "<End>", function()
        if is_open() then close() else open(height) end
    end, { silent = true, desc = "Toggle Diagnostic Panel" })

    vim.keymap.set("n", opts.keymap_workspace or "<S-End>", function()
        vim.notify(
            "Workspace diagnostics not supported. Use Trouble.nvim for a project-wide view.",
            vim.log.levels.INFO,
            { title = "Diagnostic Panel" }
        )
    end, { silent = true, desc = "Workspace diagnostics (unavailable)" })
end

return M

