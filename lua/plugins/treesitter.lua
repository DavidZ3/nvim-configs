return {
    "nvim-treesitter/nvim-treesitter",
    version = false,          -- follow latest (recommended for this plugin)
    lazy = false,             -- load at startup
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
        ensure_installed = { "lua", "javascript", "python", "c" },
        highlight = { enable = true },
        indent = { enable = true },
    },
}
