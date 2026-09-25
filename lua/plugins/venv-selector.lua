return {
  'linux-cultist/venv-selector.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  ft = 'python',
  cmd = { 'VenvSelect', 'VenvSelectCache' },
  keys = {
    { '<leader>vs', '<cmd>VenvSelect<cr>', desc = '[V]env [S]elect' },
  },
  opts = {
    options = {
      notify_user_on_venv_activation = true,
    },
  },
}
