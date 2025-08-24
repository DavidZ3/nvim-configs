return {
  "numToStr/Comment.nvim",
  dependencies = {
    -- Only needed if you want perfect comments in JSX/TSX/Svelte/etc.
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  event = "VeryLazy",
  config = function()
    local has_ts, ts_integ = pcall(function()
      return require("ts_context_commentstring.integrations.comment_nvim")
    end)

    require("Comment").setup({
      pre_hook = has_ts and ts_integ.create_pre_hook() or nil,
    })

    -- Ctrl+/ is <C-_> for Neovim (terminals send ^_)
    local map = vim.keymap.set
    -- Use the plugin’s built-ins: gcc (line), gc (op-pending/visual)
    map("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment (line)" })
    map("i", "<C-_>", "<C-o>gcc", { remap = true, desc = "Toggle comment (line, insert)" })
    map("v", "<C-_>", "gc",  { remap = true, desc = "Toggle comment (selection)" })
  end,
}

