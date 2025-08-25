-- Description: Basic Vim options and key mappings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.backspace = "indent,eol,start"
vim.opt.expandtab = true
vim.opt.hidden = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ruler = true
vim.opt.shiftwidth = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

-- Folding with Treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 4

vim.keymap.set("v", "<C-c>", '"+y', { silent = true, desc = "Yank selection to clipboard" })
vim.keymap.set("v", "<F5>", 'spell! spelllang=en_au<CR>', { silent = true, desc = "Spell Check English" })
vim.keymap.set("i", "jk", '<esc>', { silent = true, desc = "Escape using jk" })

