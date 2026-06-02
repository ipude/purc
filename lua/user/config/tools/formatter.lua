require("conform").setup({
    formatters_by_ft = {
        -- JavaScript/TypeScript
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },

        -- Web
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },

        -- Python
        python = { "black" },

        -- Lua
        lua = { "stylua" },

        -- C/C++
        c = { "clang_format" },
        cpp = { "clang_format" },

        -- Go
        go = { "gofmt" },

        -- Rust
        rustfmt = {
            prepend_args = {
                "--config",
                "tab_spaces=4",
            },
        },
        -- Shell
        sh = { "shfmt" },
        bash = { "shfmt" },

        -- Other
        toml = { "taplo" },

        -- for all types
        default_format_opts = {
            lsp_format = "fallback",
        },
    },

    -- Configure formatters with 4-space indentation
    formatters = {
        prettier = {
            prepend_args = {
                "--tab-width",
                "4",
                "--use-tabs",
                "false",
            },
        },
        black = {
            prepend_args = {
                "--line-length",
                "88",
            },
        },
        stylua = {
            prepend_args = {
                "--indent-type",
                "Spaces",
                "--indent-width",
                "4",
            },
        },
        clang_format = {
            prepend_args = {
                "-style={IndentWidth: 4, UseTab: Never}",
            },
        },
        shfmt = {
            prepend_args = {
                "-i",
                "4",
            },
        },
    },
    format_on_save = nil, -- turn it off because autosave is on
})

-- Global variable to track formatter state (enabled by default)
vim.g.conform_enabled = true

-- Toggle function
local function toggle_conform()
    vim.g.conform_enabled = not vim.g.conform_enabled
    if vim.g.conform_enabled then
        print("✓ Conform formatter enabled")
    else
        print("✗ Conform formatter disabled")
    end
end

-- Keybindings
vim.keymap.set("n", "<leader>uf", toggle_conform, {
    desc = "Toggle conform formatter on/off",
    noremap = true,
    silent = true,
})
-- Also support visual mode formatting
vim.keymap.set("v", "<leader>vf", function()
    if vim.g.conform_enabled then
        require("conform").format({
            async = false,
            lsp_fallback = true,
        })
    else
        print("Formatter is disabled. Press <Leader>ffo to enable.")
    end
end, {
    desc = "Format selection with conform",
    noremap = true,
    silent = true,
})
