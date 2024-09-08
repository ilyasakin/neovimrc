return {
  { 'tpope/vim-sleuth' },

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  {
    'm4xshen/hardtime.nvim',
    dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
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

  { 'danilamihailov/beacon.nvim' },
}
