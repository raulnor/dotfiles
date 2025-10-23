vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true       
vim.opt.relativenumber = true

vim.cmd [[
call plug#begin('~/.local/share/nvim/plugged')

Plug 'ThePrimeagen/vim-be-good'
Plug 'tpope/vim-fugitive'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

call plug#end()
]]

vim.keymap.set('n', '<leader>f', ':Files<CR>')
vim.keymap.set('n', '<leader>b', ':Buffers<CR>')
vim.keymap.set('n', '<leader>g', ':GFiles<CR>')

vim.keymap.set('n', '<leader>gg', ':G<CR>') -- Interactive git
vim.keymap.set('n', '<leader>gc', ':Git commit<CR>')
vim.keymap.set('n', '<leader>gp', ':Git push<CR>')
vim.keymap.set('n', '<leader>gb', ':Git blame<CR>')
