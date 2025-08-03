return {
  {
    'folke/trouble.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      {
        '<leader>tt',
        ':TroubleToggle<CR>',
        mode = 'n',
        desc = 'Toggle [T]rouble',
      },
    },
    opts = {},
  },
  {
    "zbirenbaum/neodim",
    event = "LspAttach",
    config = function()
      require("neodim").setup()
    end,
  }, {
  'dgagn/diagflow.nvim',
  event = 'LspAttach',
  opts = {},
},

  {
    'dmmulroy/tsc.nvim',
    dependencies = { 'folke/trouble.nvim' },
    opts =
    {
      run_as_monorepo = true,
      use_trouble_qflist = true,
    }
  }

}
