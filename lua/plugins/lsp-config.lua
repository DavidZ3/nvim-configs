return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",  -- Lua
          "pyright", -- Python
          "clangd",  -- C/C++
        },
        automatic_installation = true,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local mlsp = require("mason-lspconfig")

      -- Configure each server exactly once (prevents duplicate clients)
      local function setup_server(server)
        local opts = { capabilities = capabilities }

        if server == "lua_ls" then
          opts.settings = {
            Lua = {
              telemetry = { enable = false },
              workspace = { checkThirdParty = false },
            },
          }

        elseif server == "pyright" then
          opts.root_dir = util.root_pattern(
            "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git"
          )
          opts.single_file_support = false
          opts.settings = {
            python = { analysis = { typeCheckingMode = "basic" } },
          }

        elseif server == "clangd" then
          opts.capabilities = vim.tbl_deep_extend("force", capabilities, {
            offsetEncoding = { "utf-16" },
          })
          opts.cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--offset-encoding=utf-16",
            -- "--header-insertion=never",
            "--compile-commands-dir=.", -- set if compile_commands.json lives in ./build
          }
        end

        lspconfig[server].setup(opts)
      end

      -- Set up only the servers Mason knows about
      for _, server in ipairs(mlsp.get_installed_servers()) do
        setup_server(server)
      end

      -- Keymaps
      vim.keymap.set('n', 'K',  vim.lsp.buf.hover, {})
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
        local is_on = (cfg.virtual_text == true) or (type(cfg.virtual_text) == 'table')
        local new = not is_on
        vim.diagnostic.config({ virtual_text = new })
        vim.notify('Inline diagnostics: ' .. (new and 'ON' or 'OFF'))
      end, { desc = 'Toggle inline diagnostics' })
    end,
  },
}
