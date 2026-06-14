-- diagnostics_panel.lua
-- Place in ~/.config/nvim/lua/diagnostics_panel.lua
-- Then require it in your init.lua: require("diagnostics_panel")

local M = {}

-- ── helpers ────────────────────────────────────────────────────────────────

local severity_label = {
    [vim.diagnostic.severity.ERROR] = "Error",
    [vim.diagnostic.severity.WARN] = "Warn",
    [vim.diagnostic.severity.INFO] = "Info",
    [vim.diagnostic.severity.HINT] = "Hint",
}

local severity_icon = {
    [vim.diagnostic.severity.ERROR] = "●",
    [vim.diagnostic.severity.WARN] = "●",
    [vim.diagnostic.severity.INFO] = "●",
    [vim.diagnostic.severity.HINT] = "○",
}

local function build_lines(diags, cur_line)
    local by_line = {}
    local order = {}

    for _, d in ipairs(diags) do
        local ln = d.lnum + 1
        if not by_line[ln] then
            by_line[ln] = {}
            table.insert(order, ln)
        end
        table.insert(by_line[ln], d)
    end

    table.sort(order, function(a, b)
        local a_cur = (cur_line and a == cur_line + 1)
        local b_cur = (cur_line and b == cur_line + 1)
        if a_cur ~= b_cur then
            return a_cur
        end
        return a < b
    end)

    local lines = {}
    local hls = {}

    local function add_hl(row, col_s, col_e, grp)
        table.insert(hls, { row = row, col_s = col_s, col_e = col_e, grp = grp })
    end

    for _, ln in ipairs(order) do
        local is_cur = cur_line and (ln == cur_line + 1)

        if #lines > 0 then
            table.insert(lines, "")
        end

        -- Header: "  line 5  ◀" or "  line 4"
        local lnum_str = string.format("  line %-4d", ln)
        local header = lnum_str .. (is_cur and " ◀" or "")
        local hdr_row = #lines
        table.insert(lines, header)

        add_hl(hdr_row, 2, #lnum_str, is_cur and "DiagnosticPanelCurrentLine" or "DiagnosticPanelLineHeader")
        if is_cur then
            add_hl(hdr_row, #lnum_str, #header, "DiagnosticPanelArrow")
        end

        for _, d in ipairs(by_line[ln]) do
            local sev = severity_label[d.severity] or "?"
            local icon = severity_icon[d.severity] or "·"
            local col = d.col + 1
            local msg = d.message:gsub("\n", " ")
            local src = d.source and d.source or ""

            -- "    ● message  col 1  rustc"
            local icon_part = "    " .. icon .. "  "
            local msg_part = msg
            local meta_part = string.format("  col %d  %s", col, src)

            local entry = icon_part .. msg_part .. meta_part
            local entry_row = #lines
            table.insert(lines, entry)

            -- icon colour
            local hl_map = {
                Error = "DiagnosticError",
                Warn = "DiagnosticWarn",
                Info = "DiagnosticInfo",
                Hint = "DiagnosticHint",
            }
            add_hl(entry_row, 4, 4 + #icon, hl_map[sev] or "Normal")

            -- message (normal fg, slightly dimmed via Comment for hints)
            local msg_hl = (sev == "Hint") and "Comment" or "Normal"
            add_hl(entry_row, #icon_part, #icon_part + #msg_part, msg_hl)

            -- meta dimmed
            add_hl(entry_row, #icon_part + #msg_part, #entry, "DiagnosticPanelMeta")
        end
    end

    if #lines == 0 then
        table.insert(lines, "  ✓  no diagnostics")
        add_hl(0, 2, #"  ✓  no diagnostics", "DiagnosticPanelMeta")
    end

    return lines, hls
end

-- ── buffer / window ────────────────────────────────────────────────────────

local panel_bufnr = nil
local panel_winid = nil
local source_winid = nil
local autocmd_id = nil

local function is_valid_panel()
    return panel_bufnr
        and vim.api.nvim_buf_is_valid(panel_bufnr)
        and panel_winid
        and vim.api.nvim_win_is_valid(panel_winid)
end

local function refresh_panel()
    if not is_valid_panel() then
        return
    end
    if not source_winid or not vim.api.nvim_win_is_valid(source_winid) then
        return
    end

    local target_buf = vim.api.nvim_win_get_buf(source_winid)
    local cur_line = vim.api.nvim_win_get_cursor(source_winid)[1] - 1

    local diags = vim.diagnostic.get(target_buf)
    table.sort(diags, function(a, b)
        if a.lnum ~= b.lnum then
            return a.lnum < b.lnum
        end
        if a.severity ~= b.severity then
            return a.severity < b.severity
        end
        return a.col < b.col
    end)

    local lines, hls = build_lines(diags, cur_line)

    vim.bo[panel_bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(panel_bufnr, 0, -1, false, lines)
    vim.bo[panel_bufnr].modifiable = false

    local ns = vim.api.nvim_create_namespace("diagnostics_panel_hl")
    vim.api.nvim_buf_clear_namespace(panel_bufnr, ns, 0, -1)
    for _, h in ipairs(hls) do
        vim.api.nvim_buf_add_highlight(panel_bufnr, ns, h.grp, h.row, h.col_s, h.col_e)
    end
end

local function close_panel()
    if autocmd_id then
        pcall(vim.api.nvim_del_autocmd, autocmd_id)
        autocmd_id = nil
    end
    if panel_winid and vim.api.nvim_win_is_valid(panel_winid) then
        vim.api.nvim_win_close(panel_winid, true)
    end
    if panel_bufnr and vim.api.nvim_buf_is_valid(panel_bufnr) then
        vim.api.nvim_buf_delete(panel_bufnr, { force = true })
    end
    panel_bufnr = nil
    panel_winid = nil
    source_winid = nil
end

local function open_panel(source_win, source_buf, height)
    if is_valid_panel() then
        close_panel()
        return
    end

    local target_win = source_win or vim.api.nvim_get_current_win()
    local target_buf = source_buf or vim.api.nvim_get_current_buf()
    local cur_line = vim.api.nvim_win_get_cursor(target_win)[1] - 1

    source_winid = target_win

    local diags = vim.diagnostic.get(target_buf)
    table.sort(diags, function(a, b)
        if a.lnum ~= b.lnum then
            return a.lnum < b.lnum
        end
        if a.severity ~= b.severity then
            return a.severity < b.severity
        end
        return a.col < b.col
    end)

    local lines, hls = build_lines(diags, cur_line)

    panel_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(panel_bufnr, 0, -1, false, lines)
    vim.bo[panel_bufnr].modifiable = false
    vim.bo[panel_bufnr].buftype = "nofile"
    vim.bo[panel_bufnr].filetype = "diagnostics_panel"
    vim.bo[panel_bufnr].bufhidden = "wipe"

    local ns = vim.api.nvim_create_namespace("diagnostics_panel_hl")
    for _, h in ipairs(hls) do
        vim.api.nvim_buf_add_highlight(panel_bufnr, ns, h.grp, h.row, h.col_s, h.col_e)
    end

    vim.cmd("botright " .. height .. "split")
    panel_winid = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(panel_winid, panel_bufnr)

    local wo = vim.wo[panel_winid]
    wo.number = false
    wo.relativenumber = false
    wo.signcolumn = "no"
    wo.wrap = false
    wo.cursorline = false
    wo.foldcolumn = "0"
    wo.winfixheight = true

    vim.keymap.set("n", "q", close_panel, { buffer = panel_bufnr, silent = true })
    vim.keymap.set("n", "<Esc>", close_panel, { buffer = panel_bufnr, silent = true })

    autocmd_id = vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = target_buf,
        callback = refresh_panel,
        desc = "Refresh diagnostic panel on cursor move",
    })

    vim.api.nvim_set_current_win(target_win)
end

-- ── highlights ─────────────────────────────────────────────────────────────

local function setup_highlights()
    vim.api.nvim_set_hl(0, "DiagnosticPanelLineHeader", { link = "Comment", default = true })
    vim.api.nvim_set_hl(0, "DiagnosticPanelCurrentLine", { link = "Title", default = true })
    vim.api.nvim_set_hl(0, "DiagnosticPanelArrow", { link = "WarningMsg", default = true })
    vim.api.nvim_set_hl(0, "DiagnosticPanelMeta", { link = "Comment", default = true })
end

-- ── setup ──────────────────────────────────────────────────────────────────

function M.setup(opts)
    opts = opts or {}
    local height = opts.height or 10

    setup_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = setup_highlights,
        desc = "Re-apply DiagnosticPanel highlights after colorscheme change",
    })

    vim.keymap.set("n", "<End>", function()
        open_panel(vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf(), height)
    end, { silent = true, desc = "Toggle buffer diagnostic panel" })

    vim.keymap.set("n", "<S-End>", function()
        vim.notify(
            "Workspace diagnostic is unavailable and may be added in the future if needed.\n"
                .. "For urgent need either use Trouble or prompt AI to make something similar to the local one.",
            vim.log.levels.INFO,
            { title = "Workspace Diagnostics" }
        )
    end, { silent = true, desc = "Workspace diagnostic (unavailable)" })
end

return M
