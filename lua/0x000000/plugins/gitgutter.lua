return {
  'airblade/vim-gitgutter',
  event = 'BufRead',
  keys = {
    {
      '<leader>hp',
      ':GitGutterPreviewHunk<CR>',
      mode = 'n',
      desc = '[P]review git hunk',
    },
    {
      '<leader>hs',
      ':GitGutterStageHunk<CR>',
      mode = 'n',
      desc = '[S]tage git hunk',
    },
    {
      '<leader>hu',
      ':GitGutterUndoHunk<CR>',
      mode = 'n',
      desc = '[U]ndo git hunk',
    },
    {
      ']c',
      ':GitGutterNextHunk<CR>',
      mode = 'n',
      desc = 'Jump to [N]ext git hunk',
    },
    {
      '[c',
      ':GitGutterPrevHunk<CR>',
      mode = 'n',
      desc = 'Jump to [P]revious git hunk',
    },
  },
};
