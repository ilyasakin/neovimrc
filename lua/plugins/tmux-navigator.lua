return {
  -- C-h/j/k/l move between neovim splits and tmux panes (tmux side lives in ~/.config/tmux/tmux.conf)
  'christoomey/vim-tmux-navigator',
  cmd = { 'TmuxNavigateLeft', 'TmuxNavigateDown', 'TmuxNavigateUp', 'TmuxNavigateRight', 'TmuxNavigatePrevious' },
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  keys = {
    { '<C-h>', '<cmd>TmuxNavigateLeft<cr>', desc = 'Window left' },
    { '<C-j>', '<cmd>TmuxNavigateDown<cr>', desc = 'Window down' },
    { '<C-k>', '<cmd>TmuxNavigateUp<cr>', desc = 'Window up' },
    { '<C-l>', '<cmd>TmuxNavigateRight<cr>', desc = 'Window right' },
    { '<C-\\>', '<cmd>TmuxNavigatePrevious<cr>', desc = 'Previous window' },
  },
}
