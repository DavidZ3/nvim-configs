vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.keymap.set("v", "<C-c>", '"+y', { silent = true, desc = "Yank selection to clipboard" })
