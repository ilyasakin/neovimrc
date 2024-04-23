-- [[ Setting options ]]
vim.o.hlsearch = true
vim.wo.number = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.lazyredraw = true
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.wo.relativenumber = true
vim.g.do_filetype_lua = 1;
vim.opt.swapfile = false;
vim.opt.backup = false;
vim.opt.wrap = false;
vim.opt.guicursor = '';
vim.opt.scrolloff = 4;
vim.cmd [[set diffopt+=linematch:50]]

vim.loader.enable();

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  require '0x000000.plugins.completion',
  require '0x000000.plugins.lsp',
  require '0x000000.plugins.typescript',
  require '0x000000.plugins.which-key',
  require '0x000000.plugins.git',
  require '0x000000.plugins.theme',
  require '0x000000.plugins.statusline',
  require '0x000000.plugins.comment',
  require '0x000000.plugins.telescope',
  require '0x000000.plugins.tree-sitter',
  require '0x000000.plugins.diagnostics',
  require '0x000000.plugins.editor',
  require '0x000000.plugins.format',
  require '0x000000.plugins.copilot',
  require '0x000000.plugins.dap',
}, {})

require('0x000000.remap')
require('0x000000.keymap')
require('0x000000.signs')
require('0x000000.autocmd')
