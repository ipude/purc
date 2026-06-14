vim.api.nvim_create_user_command("DiagYankWhole", function()
    local diags = vim.diagnostic.get(0)
    if vim.tbl_isempty(diags) then
        print("No diagnostics in buffer")
        return
    end

    local lines = {}
    for _, d in ipairs(diags) do
        table.insert(lines, ("%s (%d:%d): %s"):format(d.source or "LSP", d.lnum + 1, d.col + 1, d.message))
    end

    vim.fn.setreg('"', table.concat(lines, "\n"))
    print("Buffer diagnostics yanked")
end, {})

vim.api.nvim_create_user_command("DiagYankWorkspace", function()
    local lines = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            for _, d in ipairs(vim.diagnostic.get(buf)) do
                table.insert(
                    lines,
                    ("%s:%d:%d [%s] %s"):format(
                        name ~= "" and name or "[No Name]",
                        d.lnum + 1,
                        d.col + 1,
                        d.source or "LSP",
                        d.message
                    )
                )
            end
        end
    end

    if #lines == 0 then
        print("No diagnostics in workspace")
        return
    end

    vim.fn.setreg('"', table.concat(lines, "\n"))
    print("Workspace diagnostics yanked")
end, {})
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "●",
            [vim.diagnostic.severity.WARN] = "●",
            [vim.diagnostic.severity.INFO] = "●",
            [vim.diagnostic.severity.HINT] = "●",
        },
    },
    virtual_text = false,
    underline = false,
    update_in_insert = false,
    severity_sort = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        vim.keymap.set("n", "<M-j>", function()
            vim.diagnostic.jump({ count = 1, float = false })
        end, { buffer = args.buf, desc = "Next diagnostic" })

        vim.keymap.set("n", "<M-k>", function()
            vim.diagnostic.jump({ count = -1, float = false })
        end, { buffer = args.buf, desc = "Prev diagnostic" })
    end,
})
