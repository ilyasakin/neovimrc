-- Cache compiled Lua modules; must run before anything is required
vim.loader.enable()

-- [[ Setting options ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.hlsearch = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true
vim.o.swapfile = false
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.backup = false
vim.o.wrap = false
vim.o.guicursor = ''
vim.o.scrolloff = 4
vim.opt.diffopt:append 'linematch:50'
vim.o.conceallevel = 2
vim.o.history = 100
vim.o.synmaxcol = 240
vim.g.did_install_default_menus = 1
vim.g.did_install_syntax_menu = 1

-- Auto-reload buffers when files change
vim.o.autoread = true

-- Disable unused providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Set Python provider to use our virtual environment
vim.g.python3_host_prog = vim.fn.expand '~/.config/nvim/venv/bin/python3'

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
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
  require 'plugins.supermaven',
  require 'plugins.dap',
  require 'plugins.claude-code',
  -- require 'plugins.codex',
  require 'plugins.venv-selector',
  require 'plugins.zen-mode',
  require 'plugins.tmux-navigator',
}, {
  install = { colorscheme = { 'catppuccin' } },
  rocks = { enabled = false }, -- no plugin needs luarocks
  change_detection = { notify = false },
  performance = {
    rtp = {
      -- Built-in runtime plugins that are never used. netrw stays: <leader>e and claudecode use it.
      disabled_plugins = { 'gzip', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin' },
    },
  },
})

require 'remap'
require 'keymap'
require 'signs'
require 'autocmd'
