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
vim.opt.diffopt = vim.opt.diffopt + 'linematch:50'
vim.opt.conceallevel = 2
vim.opt.hidden = true
vim.opt.history = 100
vim.opt.synmaxcol = 240
vim.g.did_install_default_menus = 1
vim.g.did_install_syntax_menu = 1

vim.loader.enable()

-- Disable unused providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Set Python provider to use our virtual environment
vim.g.python3_host_prog = vim.fn.expand('~/.config/nvim/venv/bin/python3')

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
  require 'plugins.which-key',
  require 'plugins.completion',
  require 'plugins.lsp',
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
  require 'plugins.supermaven',
  require 'plugins.dap',
  require 'plugins.db',
  require 'plugins.obsidian'
}, {})

require 'remap'
require 'keymap'
require 'signs'
require 'autocmd'
