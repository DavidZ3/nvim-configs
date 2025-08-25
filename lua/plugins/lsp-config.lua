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

      -- Configure each server exactly once via Mason
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
          -- Force Mason binary to avoid PATH/global duplicates
          opts.cmd = { vim.fn.stdpath("data") .. "/mason/bin/pyright-langserver.cmd", "--stdio" }
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

      -- Guard against double-config on reloads
      if not vim.g.__my_lsp_servers_configured then
        for _, server in ipairs(mlsp.get_installed_servers()) do
          setup_server(server)
        end
        vim.g.__my_lsp_servers_configured = true
      end

      -- Hard stop duplicate Pyright clients (keep Mason one)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local new_client = vim.lsp.get_client_by_id(args.data.client_id)
          if not new_client or new_client.name ~= "pyright" then return end

          local function is_mason_client(c)
            local exe = (c.cmd and c.cmd[1] or ""):gsub("\\", "/"):lower()
            return exe:find("/mason/bin/pyright%-langserver") ~= nil
          end

          local py_clients = vim.lsp.get_active_clients({ bufnr = args.buf, name = "pyright" })
          -- Prefer the Mason-managed client if present
          local keep = new_client
          for _, c in ipairs(py_clients) do
            if is_mason_client(c) then keep = c break end
          end
          for _, c in ipairs(py_clients) do
            if c.id ~= keep.id then
              vim.lsp.stop_client(c.id)
            end
          end
        end,
      })

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
