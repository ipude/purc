-- ===========================
-- Editor Enhancements
-- ===========================
return {
    {
        'kylechui/nvim-surround',
        keys = { 'ys', 'ds', 'cs', { 'S', mode = 'v' } },
        config = function()
            require('nvim-surround').setup({})
        end,
    },
    {
        {
            "akinsho/toggleterm.nvim",
            version = "*",
            cmd = "ToggleTerm", -- also loaded on command
            keys = { "<A-t>" }, -- lazy-load trigger
            opts = {
                size = 15,
                open_mapping = "<A-t>",
                hide_numbers = true,
                shade_terminals = false, -- keep this false because is  heavy
                -- shading_factor = 2,
                start_insert = true,
                insert_mappings = false, -- tt works in insert mode too
                terminal_mappings = true,
                persist_size = true,
                direction = "horizontal", -- no floating, ever
                close_on_exit = true,
                shell = vim.o.shell,
                auto_scroll = true,
            },
            vim.keymap.set("t", "<A-End>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
        },

        -- in your lazy.nvim plugins table
        {
            "stevearc/overseer.nvim",
            cmd = { "OverseerToggle", "OverseerRun", "OverseerQuickAction" },
            keys = {
                { "<leader>tt", "<cmd>OverseerToggle<cr>",     desc = "Task toggle" },
                { "<leader>ts", "<cmd>OverseerShell<cr>",      desc = "Task Shell" },
                { "<leader>ta", "<cmd>OverseerTaskAction<cr>", desc = "Task action" },
            },
            opts = {
                -- Task list panel on the right, taller
                task_list = {
                    direction = "bottom", -- ignored when floating, but required
                    bindings = {
                        ["<CR>"] = "RunAction",
                        ["o"]    = "OpenOutput",
                        ["s"]    = "Stop",
                        ["r"]    = "Restart",
                        ["d"]    = "Dispose",
                        ["q"]    = "Close",
                        ["?"]    = "ShowHelp",
                    },
                },

                -- Default components every task gets
                -- Keeps tasks around for 5 min after finishing so you can inspect them
                component_aliases = {
                    default = {
                        -- "display_duration",    ← remove
                        -- "on_output_summarize", ← remove
                        "on_exit_set_status",
                        { "on_complete_notify",  system = "unfocused" },
                        { "on_complete_dispose", require_view = { "SUCCESS" }, timeout = 300 },
                    },
                },

                -- Show task status in the winbar/statusline if you want it
                -- Remove this block if you don't use lualine
                -- (see lualine section below)
            },
        },
    }
}
