-- diagnostics_panel.lua
-- ~/.config/nvim/lua/diagnostics_panel.lua
-- require("diagnostics_panel").setup()
--
-- Modes:
--   mode = "hsplit"  (default) — botright split, height configurable
--   mode = "tab"               — reuses a dedicated tab; buffer is unlisted
--                                so bufferline never shows it; <End> toggles
--                                back to the previous tab

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
    vim.api.nvim_set_hl(0, "DiagPanelCurLine", { link = "Title",    default = true })
    vim.api.nvim_set_hl(0, "DiagPanelHeading", { link = "Function", default = true })
    vim.api.nvim_set_hl(0, "DiagPanelMeta",    { link = "Comment",  default = true })
    vim.api.nvim_set_hl(0, "DiagPanelMsg",     { link = "Normal",   default = true })
    vim.api.nvim_set_hl(0, "DiagPanelTree",    { link = "NonText",  default = true })
end

-- ── build ──────────────────────────────────────────────────────────────────

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
        local is_cur = (ln == cur_line)
        local hdr_hl = is_cur and "DiagPanelCurLine" or "DiagPanelHeading"
        local marker = is_cur and "› " or "■ "
        local lbl    = marker .. "line " .. tostring(ln + 1)

        if i > 1 then table.insert(lines, "") end

        local hrow = #lines
        table.insert(lines, lbl)
        hl(hrow, 0, #lbl, hdr_hl)

        local group = by_lnum[ln]
        local n     = #group

        for j, d in ipairs(group) do
            local is_last   = (j == n)
            local connector = is_last and "└─ " or "├─ "
            local icon      = SEV_ICON[d.severity] or "● "
            local msg       = d.message:gsub("\n", " ")
            local src       = d.source and ("[" .. d.source .. "]") or ""
            local entry     = connector .. icon .. msg .. (src ~= "" and ("  " .. src) or "")
            local erow      = #lines
            table.insert(lines, entry)

            hl(erow, 0, #connector, "DiagPanelTree")

            local icon_s = #connector
            local icon_e = icon_s + #icon
            hl(erow, icon_s, icon_e, SEV_HL[d.severity] or "Normal")

            local msg_s = icon_e
            local msg_e = msg_s + #msg
            hl(erow, msg_s, msg_e, "DiagPanelMsg")

            if src ~= "" then
                hl(erow, msg_e + 2, msg_e + 2 + #src, "DiagPanelMeta")
            end
        end
    end

    return lines, hls
end

-- ── panel state ────────────────────────────────────────────────────────────

local ns = vim.api.nvim_create_namespace("diag_panel")

-- S holds everything needed for both modes in one table.
-- S.tabpage is only used in tab mode (the dedicated tabpage handle).
-- S.prev_tabpage tracks which tab to return to when closing tab mode.
local S = {
    bufnr        = nil,
    winid        = nil,
    src_winid    = nil,
    autocmd_id   = nil,
    tabpage      = nil,   -- tab mode only
    prev_tabpage = nil,   -- tab mode only
}

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

-- ── shared buffer setup ────────────────────────────────────────────────────

local function make_buf()
    local bufnr = vim.api.nvim_create_buf(false, true)   -- listed=false, scratch=true
    -- buflisted is already false from create_buf(false, …) — bufferline won't
    -- show it.  buftype=nofile means it has no backing file and won't prompt
    -- to save.  bufhidden=wipe means it is destroyed when the window closes.
    vim.bo[bufnr].buftype   = "nofile"
    vim.bo[bufnr].filetype  = "diagnostics_panel"
    vim.bo[bufnr].bufhidden = "wipe"
    vim.bo[bufnr].swapfile  = false
    return bufnr
end

local function apply_win_opts(winid, km_close)
    vim.wo[winid].number         = false
    vim.wo[winid].relativenumber = false
    vim.wo[winid].signcolumn     = "no"
    vim.wo[winid].wrap           = true
    vim.wo[winid].linebreak      = true   -- break at word boundaries, not mid-word
    vim.wo[winid].cursorline     = false
    vim.wo[winid].foldcolumn     = "0"
    vim.wo[winid].winbar         = ""
    vim.wo[winid].statusline     = ""
end

-- ── close ──────────────────────────────────────────────────────────────────

local function close()
    if S.autocmd_id then
        pcall(vim.api.nvim_del_autocmd, S.autocmd_id)
        S.autocmd_id = nil
    end

    if S.tabpage then
        -- Tab mode: switch back to the source tab first, then close the
        -- panel tab.  We go back first so the cursor lands where the user
        -- was, not on whatever tab Neovim picks after closing.
        if S.prev_tabpage and vim.api.nvim_tabpage_is_valid(S.prev_tabpage) then
            vim.api.nvim_set_current_tabpage(S.prev_tabpage)
        end
        if vim.api.nvim_tabpage_is_valid(S.tabpage) then
            -- tabclose the tab; wipe=true on the buf handles buffer cleanup
            local tabnr = vim.api.nvim_tabpage_get_number(S.tabpage)
            pcall(vim.cmd, tabnr .. "tabclose")
        end
        S.tabpage      = nil
        S.prev_tabpage = nil
    else
        -- Hsplit mode
        if S.winid and vim.api.nvim_win_is_valid(S.winid) then
            vim.api.nvim_win_close(S.winid, true)
        end
    end

    -- Buffer is wiped automatically by bufhidden=wipe when the window
    -- closes, but guard in case something went sideways.
    if S.bufnr and vim.api.nvim_buf_is_valid(S.bufnr) then
        pcall(vim.api.nvim_buf_delete, S.bufnr, { force = true })
    end

    S.bufnr = nil; S.winid = nil; S.src_winid = nil
end

-- ── open: hsplit ───────────────────────────────────────────────────────────

local function open_hsplit(height)
    local src_win  = vim.api.nvim_get_current_win()
    local src_buf  = vim.api.nvim_get_current_buf()
    local cur_line = vim.api.nvim_win_get_cursor(src_win)[1] - 1

    S.src_winid = src_win
    S.bufnr     = make_buf()

    local diags = vim.diagnostic.get(src_buf)
    table.sort(diags, function(a, b)
        if a.lnum ~= b.lnum then return a.lnum < b.lnum end
        return a.severity < b.severity
    end)
    render(diags, cur_line)

    vim.cmd("botright " .. height .. "split")
    S.winid = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(S.winid, S.bufnr)

    apply_win_opts(S.winid)
    vim.wo[S.winid].winfixheight = true

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

-- ── open: tab ──────────────────────────────────────────────────────────────
--
-- Strategy: open a *new* tab with a scratch buffer using nvim_open_win +
-- nvim_win_set_config rather than :tabnew (which always creates a new file
-- buffer and stomps the current buffer list).
--
-- Steps:
--   1. Remember the current tabpage so we can return to it on close.
--   2. Open a new tab via vim.cmd("$tabnew") — this is unavoidable to get a
--      real tabpage, but we immediately replace the auto-created buffer with
--      our unlisted scratch buffer and delete the throwaway one.
--   3. Set up the window/buffer exactly like hsplit mode.
--   4. Track S.tabpage so close() knows to :tabclose instead of :close.

local function open_tab()
    local src_win  = vim.api.nvim_get_current_win()
    local src_buf  = vim.api.nvim_get_current_buf()
    local cur_line = vim.api.nvim_win_get_cursor(src_win)[1] - 1

    S.src_winid    = src_win
    S.prev_tabpage = vim.api.nvim_get_current_tabpage()
    S.bufnr        = make_buf()

    local diags = vim.diagnostic.get(src_buf)
    table.sort(diags, function(a, b)
        if a.lnum ~= b.lnum then return a.lnum < b.lnum end
        return a.severity < b.severity
    end)
    render(diags, cur_line)

    -- Open a new tab.  $tabnew creates an empty unnamed buffer; we will
    -- replace it immediately so bufferline never has a chance to list it.
    local throwaway_buf = vim.api.nvim_get_current_buf()
    vim.cmd("$tabnew")
    -- At this point we are in the new tab.
    S.tabpage = vim.api.nvim_get_current_tabpage()
    S.winid   = vim.api.nvim_get_current_win()

    -- Replace the throwaway buffer that :tabnew created.
    local new_throwaway = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_buf(S.winid, S.bufnr)
    -- Delete the auto-created buffer silently.
    pcall(vim.api.nvim_buf_delete, new_throwaway, { force = true })

    apply_win_opts(S.winid)

    local km = function(lhs, rhs)
        vim.keymap.set("n", lhs, rhs, { buffer = S.bufnr, silent = true })
    end
    km("q",     close)
    km("<Esc>", close)

    -- Refresh when the user moves in the source buffer.
    S.autocmd_id = vim.api.nvim_create_autocmd({ "CursorMoved", "DiagnosticChanged" }, {
        buffer   = src_buf,
        callback = refresh,
    })
    -- If the source window is closed, clean up.
    vim.api.nvim_create_autocmd("WinClosed", {
        pattern  = tostring(src_win),
        once     = true,
        callback = close,
    })
end

-- ── setup ──────────────────────────────────────────────────────────────────

function M.setup(opts)
    opts = opts or {}

    local mode   = opts.mode   or "hsplit"   -- "hsplit" | "tab"
    local height = opts.height or 10         -- hsplit only

    setup_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_highlights })

    vim.keymap.set("n", opts.keymap or "<S-End>", function()
        if is_open() then
            close()
        elseif mode == "tab" then
            open_tab()
        else
            open_hsplit(height)
        end
    end, { silent = true, desc = "Toggle Diagnostic Panel" })
end

return M

