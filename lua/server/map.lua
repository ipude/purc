-- Rust (filetype-specific via autocmd)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(ev)
    local opts = { buffer = ev.buf }
    map("n", "<leader>zc", "<cmd>Cargo check<cr>", vim.tbl_extend("force", opts, { desc = "Cargo check" }))
    map("n", "<leader>zC", "<cmd>Cargo clean<cr>", vim.tbl_extend("force", opts, { desc = "Cargo clean" }))
    map("n", "<leader>zz", "<cmd>Cargo run<cr>", vim.tbl_extend("force", opts, { desc = "Cargo run" }))
    map("n", "<leader>zb", "<cmd>Cargo build<cr>", vim.tbl_extend("force", opts, { desc = "Cargo build" }))
    map("n", "<leader>zu", "<cmd>Cargo update<cr>", vim.tbl_extend("force", opts, { desc = "Cargo update" }))
    map("n", "<leader>zr", "<cmd>CargoReload<cr>", vim.tbl_extend("force", opts, { desc = "Cargo reload" }))
  end,
})

-- Go (filetype-specific via autocmd)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function(ev)
    local opts = { buffer = ev.buf }
    local function goterm(cmd)
      return function()
        vim.cmd("split | terminal " .. cmd)
      end
    end

    map("n", "<leader>zz", goterm("go run ."), vim.tbl_extend("force", opts, { desc = "Go run" }))
    map("n", "<leader>zb", goterm("go build ."), vim.tbl_extend("force", opts, { desc = "Go build" }))
    map("n", "<leader>zt", goterm("go test ."), vim.tbl_extend("force", opts, { desc = "Go test" }))
    map("n", "<leader>zT", goterm("go test ./..."), vim.tbl_extend("force", opts, { desc = "Go test all" }))
    map("n", "<leader>zm", goterm("go mod tidy"), vim.tbl_extend("force", opts, { desc = "Go mod tidy" }))
    map("n", "<leader>zv", goterm("go vet ."), vim.tbl_extend("force", opts, { desc = "Go vet" }))
  end,
})
