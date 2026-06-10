-- ===========================
-- File Exploration & Navigation
-- ===========================
return {
    -- lua/plugins/oil.lua  (or wherever your plugin specs live)
    {
        "stevearc/oil.nvim",
        lazy = true,
        keys = {
            { "-", "<cmd>Oil<CR>", mode = "n", desc = "Open parent directory" },
        },
        opts = {
            -- Disable LSP file-methods entirely — this is what triggers the
            -- "update all references?" prompt that causes your crash
            lsp_file_methods = {
                enabled = false,
            },

            -- Optional but recommended quality-of-life settings
            default_file_explorer = true,
            skip_confirm_for_simple_edits = true,
            view_options = {
                show_hidden = true,
            },
        },
    },
    -- lua/plugins/fzf-lua.lua
    {
        "ibhagwan/fzf-lua",
        keys = {
            { "<leader>fz", desc = "FzfLua" },
            { "<leader>fd", desc = "Find files CWD" },
            { "<leader>fo", desc = "Recent files" },
            { "<leader>fc", desc = "Find config files" },
            { "<leader>fih", desc = "Find Files in HOME" },
            { "<leader>fir", desc = "Find Files in ROOT" },
            { "<leader>dw", desc = "Workspace diagnostics" },
            { "<leader>gd", desc = "Live grep CWD" },
            { "<leader>gc", desc = "Grep config" },
            { "<leader>gih", desc = "Grep home" },
            { "<leader>gir", desc = "Grep root" },
            { "<leader>Gc", desc = "Git commits" },
            { "<leader>Gs", desc = "Git status" },
            { "<leader>ef", desc = "FZF files in typed dir" },
            { "<leader>eg", desc = "FZF grep in typed dir" },
        },

        config = function()
            require("tools.fzf")
        end,
    },
    {
        url = "https://codeberg.org/andyg/leap.nvim",
        lazy = true,
        keys = {
            { "m", "<Plug>(leap-forward)", mode = { "n", "x", "o" }, desc = "Leap forward" },
            { "M", "<Plug>(leap-backward)", mode = { "n", "x", "o" }, desc = "Leap backward" },
            { "gm", "<Plug>(leap-from-window)", mode = { "n" }, desc = "Leap from window" },
        },
        config = function()
            require("leap").setup({
                max_phase_one_targets = nil,
                max_highlighted_traversal_targets = 10,
                case_sensitive = false,
                equivalence_classes = { " \t\r\n" },
                substitute_chars = {},
                safe_labels = "sfnut/SFNLHMUGTZ?",
                labels = "sfnjklhodweimbuyvrgtaqpcxz/SFNJKLHODWEIMBUYVRGTAQPCXZ?",
                special_keys = {
                    repeat_search = "<enter>",
                    next_phase_one_target = "<enter>",
                    next_target = { "<enter>", ";" },
                    prev_target = { "<tab>", "," },
                    next_group = "<space>",
                    prev_group = "<tab>",
                    multi_accept = "<enter>",
                    multi_revert = "<backspace>",
                },
            })

            -- Restore highlighting for unlabeled phase-one targets (replaces removed option)
            require("leap").opts.on_beacons = function(targets)
                for _, t in ipairs(targets) do
                    if not t.label and not t.beacon and t.chars and t.is_previewable ~= false then
                        t.beacon = { 0, { virt_text = { { table.concat(t.chars), "LeapMatch" } } } }
                    end
                end
            end
        end,
    },
    {
        "mikavilpas/yazi.nvim",
        keys = {
            {
                "<leader>od",
                "<cmd>Yazi<cr>",
                desc = "Open Yazi in CWD",
            },
            {
                "<leader>oc",
                function()
                    require("yazi").yazi(nil, vim.fn.stdpath("config"))
                end,
                desc = "Open in Runtime",
            },
            {
                "<leader>ou",
                function()
                    require("yazi").yazi(nil, vim.fn.stdpath("config") .. "/lua/user/")
                end,
                desc = "Open  in /lua/user/",
            },
            {
                "<leader>oj",
                function()
                    vim.ui.input({
                        prompt = " Yazi dir: ",
                        default = vim.fn.expand("~"),
                        completion = "dir",
                    }, function(input)
                        if not input or input == "" then
                            return
                        end

                        local path = vim.fn.expand(input) -- resolves ~, $VARS, etc.

                        if vim.fn.isdirectory(path) == 0 then
                            vim.notify("Not a directory: " .. path, vim.log.levels.WARN)
                            return
                        end

                        require("yazi").yazi(nil, path)
                    end)
                end,
                desc = "Open Yazi in typed dir",
            },
        },
        opts = {
            open_for_directories = false, -- Keep oil as default
            keymaps = {
                show_help = "<f1>",
                "<leader>yoh",
                open_file_in_vertical_split = "<c-v>",
                open_file_in_horizontal_split = "<c-x>",
                open_file_in_tab = "<c-t>",
                grep_in_directory = "<c-g>",
                replace_in_directory = "<c-r>",
                cycle_open_buffers = "<tab>",
                copy_relative_path_to_selected_files = "<c-y>",
                send_to_quickfix_list = "<c-q>",
            },
        },
    },
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "ibhagwan/fzf-lua",
        },
        keys = {
            { "<leader>lg", "<cmd>Neogit<cr>", desc = "Neogit" },
        },
        config = true,
    },
}
