return {
    {
        "hrsh7th/cmp-nvim-lsp",
    },
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
        -- optional but improves regex-powered snippets
        build = "make install_jsregexp",
        config = function()
            local ls = require("luasnip")

            -- Load community snippets (VSCode format)
            require("luasnip.loaders.from_vscode").lazy_load()

            -- QoL: keep last snippet around for jumping; update on text change
            ls.config.set_config({
                history = true,
                updateevents = "TextChanged,TextChangedI",
            })

            -- Snippet navigation
            vim.keymap.set({ "i", "s" }, "<C-j>", function()
                if ls.jumpable(1) then ls.jump(1) end
            end, { silent = true, desc = "Next snippet placeholder" })

            vim.keymap.set({ "i", "s" }, "<C-k>", function()
                if ls.jumpable(-1) then ls.jump(-1) end
            end, { silent = true, desc = "Prev snippet placeholder" })

            -- Expand current trigger or jump if already expanded
            vim.keymap.set({ "i", "s" }, "<C-l>", function()
                if ls.expand_or_jumpable() then ls.expand_or_jump() end
            end, { silent = true, desc = "Expand or jump snippet" })

            -- Choice nodes (if your snippet uses them)
            vim.keymap.set({ "i", "s" }, "<C-h>", function()
                if ls.choice_active() then ls.change_choice(1) end
            end, { silent = true, desc = "Cycle snippet choice" })
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }, {
                    { name = "buffer" },
                }),
            })
        end,
    },
}
