return {
  "iamcco/markdown-preview.nvim",
  ft = { "markdown" },
  cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
  build = function()
    vim.fn["mkdp#util#install"]()  -- runs the plugin’s own installer
  end,
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
}
