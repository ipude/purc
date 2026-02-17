-- -- Add a handler for the workspace/diagnostic/refresh request
-- vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
--     local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
--     local buffers = vim.api.nvim_list_bufs()
--     for _, buf in ipairs(buffers) do
--         vim.diagnostic.reset(ns, buf)
--     end
--     return vim.NIL
-- end
-- Just acknowledge the refresh request without resetting diagnostics
-- vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, _)
--     return vim.NIL
-- end

map("n", "<leader>cc", "<cmd>Cargo check<cr>", {desc = "Cargo check"})
map("n", "<leader>cC", "<cmd>Cargo clean<cr>", {desc = "Cargo clean"})
map("n", "<leader>cz", "<cmd>Cargo run<cr>", {desc = "Cargo run"})
map("n", "<leader>cb", "<cmd>Cargo build<cr>", {desc = "Cargo build"})
map("n", "<leader>cu", "<cmd>Cargo update<cr>", {desc = "Cargo update"})
map("n", "<leader>cr", "<cmd>LspCargoReload<cr>", {desc = "Cargo Lsp Reload"})

-- SILENCE ALL LSP LOGS (nuclear option for Termux)
vim.lsp.set_log_level('OFF')  -- Was 'DEBUG', now completely silent

local lspconfig = require('lspconfig')
local util = require('lspconfig.util')

lspconfig.rust_analyzer.setup({
    cmd = { 'rust-analyzer' },
    
    capabilities = _G.blink_capabilities,
    
    root_dir = function(fname)
        return util.root_pattern('Cargo.toml')(fname)
    end,
    
    single_file_support = false,
    
    settings = {
        ['rust-analyzer'] = {
            cargo = { 
                allFeatures = true,
                buildScripts = {
                    enable = true,
                },
            },
            
            check = { 
                command = 'clippy',
                extraArgs = { '--no-deps' },
            },
            
            procMacro = { 
                enable = true,
                attributes = {
                    enable = true,
                },
            },
            
            diagnostics = {
                enable = true,
                refresh = {
                    workspace = {
                        enable = true, 
                    }
                },
                disabled = {
                    "unresolved-proc-macro",
                    "unresolved-macro-call",
                },
                experimental = {
                    enable = false,
                },
            },

            restartServerOnConfigChange = {
                enable = true 
            },
            
            cachePriming = {
                enable = true,
                numThreads = 0,
            },
            
            checkOnSave = true,
            
            -- TERMUX-SPECIFIC: Help with workspace detection
            linkedProjects = {},
            files = {
                excludeDirs = {".git"},
                watcher = "server", -- new 
            },
        },
    },
})
