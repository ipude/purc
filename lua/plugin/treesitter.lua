return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = true,
        build = ":TSUpdate",
        event = "BufReadPre",

        config = function()
            vim.defer_fn(function()
                -- 1. Load & install
                require("nvim-treesitter").setup({
                    install_dir = vim.fn.stdpath("data") .. "/site",
                })

                require("nvim-treesitter")
                    .install({
                        "lua", "javascript", "zig", "go",
                        "python", "html", "css",
                    })
                    :wait(300000)

                -- 2. Start treesitter on current buffer
                pcall(vim.treesitter.start)

                -- 3. Re-apply config to current window/buffer directly
                local wo = vim.wo
                local bo = vim.bo
                wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                wo.foldmethod = "expr"
                wo.foldlevel = 99
                bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                -- 4. Future buffers via FileType
                vim.api.nvim_create_autocmd("FileType", {
                    callback = function()
                        local ok = pcall(vim.treesitter.start)
                        if not ok then return end

                        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                        vim.wo.foldmethod = "expr"
                        vim.wo.foldlevel = 99
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end,
                })

            end, 50)
        end,
    },
}
