return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                PATH = "prepend", -- ensures Mason's bin is first; "pyright-langserver" resolves to Mason's
            })
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pyright", "clangd" }, -- install only
                automatic_installation = true,
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local lspconfig = require("lspconfig")
            local util = require("lspconfig.util")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Lua
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        telemetry = { enable = false },
                        workspace = { checkThirdParty = false },
                    },
                },
            })

            -- Python (Mason's pyright will be used via PATH=prepend; no need to set cmd)
            lspconfig.pyright.setup({
                capabilities = capabilities,
                root_dir = util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git"),
                single_file_support = false,
                settings = { python = { analysis = { typeCheckingMode = "basic" } } },
            })

            -- C/C++
            lspconfig.clangd.setup({
                capabilities = vim.tbl_deep_extend("force", capabilities, { offsetEncoding = { "utf-16" } }),
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--completion-style=detailed",
                    "--offset-encoding=utf-16",
                    '--fallback-style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never, ContinuationIndentWidth: 4}',
                    "--compile-commands-dir=.",
                },
            })

            -- Keymaps & diagnostics
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {})
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
            vim.keymap.set('n', '<leader>e', function() vim.diagnostic.open_float() end, {})

            vim.diagnostic.config({ virtual_text = true })
            vim.keymap.set('n', '<space>E', function()
                local cfg = vim.diagnostic.config()
                local on = (cfg.virtual_text == true) or (type(cfg.virtual_text) == 'table')
                vim.diagnostic.config({ virtual_text = not on })
                vim.notify('Inline diagnostics: ' .. ((not on) and 'ON' or 'OFF'))
            end, { desc = 'Toggle inline diagnostics' })
        end,
    },
}
