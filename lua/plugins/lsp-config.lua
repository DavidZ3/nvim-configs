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
                ensure_installed = { "lua_ls", "pyright", "clangd", "biome" }, -- install only
                automatic_installation = true,
            })
        end,
    },
    {
        "ray-x/lsp_signature.nvim",
        event = "InsertEnter",
        opts = {
            bind = true,
            handler_opts = {
                border = "rounded"
            }
        },
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            -- Capabilities (for nvim-cmp, etc.)
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            ---------------------------------------------------------------------------
            -- Configure servers (override defaults), then enable them
            ---------------------------------------------------------------------------

            -- Lua (lua_ls)
            vim.lsp.config("lua_ls", {
                capabilities = capabilities,
                settings = {
                    Lua = {
                        telemetry = { enable = false },
                        workspace = { checkThirdParty = false },
                    },
                },
            })
            vim.lsp.enable("lua_ls")

            -- Python (pyright)
            vim.lsp.config("pyright", {
                capabilities = capabilities,
                single_file_support = false,
                settings = {
                    python = {
                        analysis = {
                            venv = "env_f8d443c5aed58962629460105d4ac0ac",
                            venvPath = "C:/Users/dzhou/python_environments/",
                            pythonVersion = "3.6.2",
                            pythonPlatform = "Windows",

                            extraPaths = {
                                ".",
                                "Tools/cochlear_system5_sp16",
                                "Tools/cochlear_system5_sp16/Toolbox",
                                "Tools/cochlear_system5_sp16/Scripts/",
                            },
                        },
                    },
                },
            })
            vim.lsp.enable("pyright")

            -- C/C++ (clangd)
            vim.lsp.config("clangd", {
                capabilities = vim.tbl_deep_extend("force", capabilities, { offsetEncoding = { "utf-16" } }),
                cmd = {
                    "clangd",
                    "--fallback-style=webkit",
                    "--compile-commands-dir=.",
                },
            })
            vim.lsp.enable("clangd")

            ---------------------------------------------------------------------------
            -- Keymaps & diagnostics
            ---------------------------------------------------------------------------
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {})
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Find references' })
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
            -- vim.keymap.set('n', '<leader>e', function() vim.diagnostic.open_float() end, {})
            -- vim.keymap.set("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Document symbols" })
            -- vim.keymap.set("n", "<leader>ws", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>",
            --     { desc = "Workspace symbols" })

            vim.diagnostic.config({ virtual_text = false })
            vim.keymap.set('n', '<space>E', function()
                local cfg = vim.diagnostic.config()
                local on = (cfg.virtual_text == true) or (type(cfg.virtual_text) == 'table')
                vim.diagnostic.config({ virtual_text = not on })
                vim.notify('Inline diagnostics: ' .. ((not on) and 'ON' or 'OFF'))
            end, { desc = 'Toggle inline diagnostics' })
        end,
    }
    ,
}
