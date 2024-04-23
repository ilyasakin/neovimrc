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
vim.g.do_filetype_lua = 1
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.wrap = false
vim.opt.guicursor = ''
vim.opt.scrolloff = 4
vim.cmd [[set diffopt+=linematch:50]]

vim.loader.enable()

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
  require 'plugins.completion',
  require 'plugins.lsp',
  require 'plugins.typescript',
  require 'plugins.which-key',
  require 'plugins.git',
  require 'plugins.theme',
  require 'plugins.statusline',
  require 'plugins.comment',
  require 'plugins.telescope',
  require 'plugins.tree-sitter',
  require 'plugins.diagnostics',
  require 'plugins.editor',
  require 'plugins.format',
  require 'plugins.copilot',
  require 'plugins.dap',
}, {})

require 'remap'
require 'keymap'
require 'signs'
require 'autocmd'
