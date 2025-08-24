return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "nvimtools/none-ls-extras.nvim",
    },
    config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
            source = {
                null_ls.builtins.formatting.stylua,

                -- Python: import sorter
                null_ls.builtins.formatting.isort.with({
                    extra_args = { "--profile=black", "--line-length", "100" }, -- nice defaults
                }),

                -- Python: diagnostics (PEP8 via flake8/pycodestyle)
                require("none-ls.diagnostics.flake8").with({
                    extra_args = {
                        "--max-line-length=100",
                        "--extend-ignore=W503,E501,E226,E402,E731,E712,E701",
                    },
                }),

                -- C / C++ formatter
                null_ls.builtins.formatting.clang_format.with({
                    filetypes = { "c", "cpp", "objc", "objcpp" },
                    extra_args = {
                        "--style=file",            -- use .clang-format if present
                        "--fallback-style=LLVM",   -- fallback when no .clang-format found
                    }
                }),
            }
        })
        vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
    end
}
