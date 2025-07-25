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
    'LunarVim/bigfile.nvim',
    event = 'VeryLazy',
  },

  {
    'f-person/git-blame.nvim',
    event = 'VeryLazy',
    opts = {}, -- this is equalent to setup({}) function
  },

  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {},
  },

  { 'danilamihailov/beacon.nvim', event = 'CursorMoved' },
}
