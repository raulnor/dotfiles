vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.clipboard = 'unnamedplus'
vim.opt.number = true       
vim.opt.relativenumber = true

vim.cmd [[
call plug#begin('~/.local/share/nvim/plugged')

Plug 'ThePrimeagen/vim-be-good'
Plug 'tpope/vim-fugitive'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

Plug 'elixir-editors/vim-elixir'	" Syntax highlighting
Plug 'neovim/nvim-lspconfig'		" LSP support
Plug 'hrsh7th/nvim-cmp'			" Autocompletion
Plug 'hrsh7th/cmp-nvim-lsp'	" LSP completion source

call plug#end()
]]

vim.keymap.set('n', '<leader>f', ':Files<CR>')
vim.keymap.set('n', '<leader>b', ':Buffers<CR>')
vim.keymap.set('n', '<leader>g', ':GFiles<CR>')

vim.keymap.set('n', '<leader>gg', ':G<CR>') -- Interactive git
vim.keymap.set('n', '<leader>gc', ':Git commit<CR>')
vim.keymap.set('n', '<leader>gp', ':Git push<CR>')
vim.keymap.set('n', '<leader>gb', ':Git blame<CR>')

vim.lsp.config.elixirls = {
  cmd = { 'elixir-ls' },
  filetypes = { 'elixir', 'eelixir', 'heex', 'surface' },
  root_dir = vim.fs.root(0, { 'mix.exs', '.git' }),
}

vim.lsp.enable('elixirls')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
})
