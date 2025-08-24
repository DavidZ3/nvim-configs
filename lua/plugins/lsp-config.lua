return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",  -- Lua
                    "pyright", -- Python
                    "clangd",  -- C/C++

                }
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")

            -- Optional: better completion capabilities if you use nvim-cmp
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            -- local capabilities = require("cmp_nvim_lsp").default_capabilities() -- if using cmp


            lspconfig.lua_ls.setup({})


            -- Python
            lspconfig.pyright.setup({
                capabilities = capabilities,
                settings = { python = { analysis = { typeCheckingMode = "basic" } } }, -- tweak if you like
            })

            -- C/C++
            lspconfig.clangd.setup({
                capabilities = vim.tbl_deep_extend("force", capabilities, {
                    -- Avoid "multiple different client offset_encodings" warnings
                    offsetEncoding = { "utf-16" },
                }),
                -- Useful defaults; comment out what you don’t want
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--completion-style=detailed",
                    "--offset-encoding=utf-16",
                    -- "--header-insertion=never",
                    "--compile-commands-dir=.", -- set if compile_commands.json lives in ./build
                },
            })
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {})
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
            vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', {})

            -- Make inline diagnostics ON by default
            vim.diagnostic.config({ virtual_text = true })

            -- Toggle based on the real current state (not a local variable)
            vim.keymap.set('n', '<space>E', function()
                local cfg = vim.diagnostic.config()
                -- In Neovim, a table value means "enabled with options"
                local is_on = (cfg.virtual_text == true) or (type(cfg.virtual_text) == 'table')
                local new = not is_on
                vim.diagnostic.config({ virtual_text = new })
                vim.notify('Inline diagnostics: ' .. (new and 'ON' or 'OFF'))
            end, { desc = 'Toggle inline diagnostics' })
        end
    }
}
