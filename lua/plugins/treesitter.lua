-- lua/plugins/treesitter.lua
return {
  -- Core Tree-sitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    opts = {
      -- Make sure C works
      ensure_installed = {
        "c", "cpp", "lua", "vim", "vimdoc", "query",
        "bash", "python", "json", "yaml", "markdown", "regex",
        "javascript", "typescript", "cmake", "go", "rust",
      },
      sync_install = false,
      auto_install = true,

      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        -- You can disable highlight per-language if needed:
        -- disable = { "latex" },
      },

      indent = {
        enable = true,
        disable = { "yaml" }, -- yaml indent can be quirky
      },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          scope_incremental = "<S-CR>",
          node_decremental = "<BS>",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)

      -- (Optional) Use Tree-sitter for folds
      -- vim.opt.foldmethod = "expr"
      -- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    end,
  },

  -- Sticky context line at the top
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      enable = true,
      max_lines = 0,
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 20,
      trim_scope = "outer",
      mode = "cursor",     -- try "topline" if you prefer
      separator = nil,     -- e.g. "─" for a visible divider
      zindex = 20,
      on_attach = nil,
    },
  },
}

