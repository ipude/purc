-- ===========================
-- Completion (load on insert)
-- ===========================
return {
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" },
        event = { "InsertEnter", "CmdlineEnter" },
        version = "1.*",

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            keymap = {
                preset = "default",
                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide", "fallback" },
                ["<C-y>"] = { "select_and_accept", "fallback" },
                ["<cr>"] = { "select_and_accept", "fallback" },

                ["<F1>"] = { "select_prev", "fallback" },
                ["<Tab>"] = { "select_next", "fallback" },
                ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
                ["<C-n>"] = { "select_next", "fallback_to_mappings" },

                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            },

            appearance = {
                nerd_font_variant = "mono",
            },

            completion = {
                documentation = { auto_show = false },
                menu = {
                    draw = {
                        columns = { { "kind_icon" }, { "label", gap = 1 } }, -- drop label_description
                        components = {
                            label = {
                                width = { fill = true, max = 40 }, -- cap label width
                                text = function(ctx)
                                    -- show only the label, not the detail (signature body)
                                    return ctx.label
                                end,
                            },
                        },
                    },
                },
            },

            sources = {
                default = { "lsp", "path", "snippets" },
            },

            fuzzy = { implementation = "prefer_rust" },

            cmdline = {
                keymap = { preset = "inherit" },
                completion = {
                    menu = { auto_show = true },
                },
            },
        },

        opts_extend = { "sources.default" },

        config = function(_, opts)
            require("blink.cmp").setup(opts)

            -- now blink is loaded, safe to merge capabilities
            local base = vim.lsp.protocol.make_client_capabilities()
            vim.lsp.config("*", {
                capabilities = require("blink.cmp").get_lsp_capabilities(base),
            })
        end,
    },
}
