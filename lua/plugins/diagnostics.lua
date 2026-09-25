return {
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      {
        '<leader>tt',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Toggle [T]rouble',
      },
    },
    opts = {},
  },

  {
    'dgagn/diagflow.nvim',
    event = 'LspAttach',
    opts = {},
  },

  {
    'dmmulroy/tsc.nvim',
    cmd = 'TSC',
    dependencies = { 'folke/trouble.nvim' },
    opts = {
      run_as_monorepo = true,
      use_trouble_qflist = true,
    },
  },
}
