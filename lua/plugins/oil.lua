return {
  'stevearc/oil.nvim',
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  lazy = false,
  opts = {
    float = {
      preview_split = "right", -- only affects :Oil --float
      override = function(conf) return conf end,
    },
    use_default_keymaps = true,
    keymaps = {
      ["<C-p>"] = false,
      ["<C-l>"] = {
        callback = function()
          require("oil").open_preview({ vertical = true, split = "botright" })
        end,
        mode = "n",
        desc = "Preview (right)",
      },
      ["<C-;>"] = { "actions.refresh", mode = "n", desc = "Refresh" },
    },
  },
  config = function(_, opts)
    require("oil").setup(opts)
    vim.opt.splitright = true -- ensure right-side splits in normal windows
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  end,
}

