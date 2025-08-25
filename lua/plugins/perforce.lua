return {
    "ngemily/vim-vp4",
    config = function()
        vim.g.vp4_allow_open_depot_file = true
        vim.keymap.set("n", "<Leader>dp", "<CMD>Vp4Diff p<CR>", { silent = true, desc = "Diff against previous." })

    end
}
