return {
  { 'tpope/vim-sleuth', event = 'BufReadPre' },

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = 'BufReadPost',
    opts = {},
  },

  {
    'm4xshen/hardtime.nvim',
    dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
    cmd = { 'Hardtime' },
    opts = {
      enabled = false,
    },
  },

  {
    -- bigfile: turns off LSP/treesitter/etc. on huge files (replaces bigfile.nvim).
    -- Also provides the terminal used by claudecode.nvim.
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
    },
  },

  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {},
  },

  { 'danilamihailov/beacon.nvim', event = 'CursorMoved' },
}
