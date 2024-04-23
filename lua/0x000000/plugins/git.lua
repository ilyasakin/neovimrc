return {
  {
    'tpope/vim-fugitive',
    event = "VeryLazy",
  },
  {
    'lewis6991/gitsigns.nvim',
    event = "VeryLazy",
    opts = {
      signs = {
        add = {
          hl = "GitSignsAdd",
          text = "|",
          numhl = "GitSignsAddNr",
          linehl = "GitSignsAddLn"
        },
        change = {
          hl = "GitSignsChange",
          text = "|",
          numhl = "GitSignsChangeNr",
          linehl = "GitSignsChangeLn"
        },
        delete = {

          hl = "GitSignsDelete",
          text = "_",
          numhl = "GitSignsDeleteNr",
          linehl = "GitSignsDeleteLn"
        },
        topdelete = {
          hl = "GitSignsDelete",
          text = "‾",
          numhl = "GitSignsDeleteNr",
          linehl = "GitSignsDeleteLn"
        },
        changedelete = {
          hl = "GitSignsChange",
          text = "~",
          numhl = "GitSignsChangeNr",
          linehl = "GitSignsChangeLn",
        },
      },
      signcolumn = false, -- Toggle with `:Gitsigns toggle_signs`
      numhl = true,       -- Toggle with `:Gitsigns toggle_numhl`
      linehl = false,     -- Toggle with `:Gitsigns toggle_linehl`
      word_diff = false,  -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      attach_to_untracked = true,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil,  -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      preview_config = {
        -- Options passed to nvim_open_win
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
      yadm = {
        enable = false,
      },
    },
    keys = {
      {
        '<leader>hp',
        ':lua require"gitsigns".preview_hunk()<CR>',
        mode = 'n',
        desc = '[P]review git hunk',
      },
      {
        '<leader>hs',
        ':lua require"gitsigns".stage_hunk()<CR>',
        mode = 'n',
        desc = '[S]tage git hunk',
      },
      {
        '<leader>hu',
        ':lua require"gitsigns".undo_stage_hunk()<CR>',
        mode = 'n',
        desc = '[U]ndo git hunk',
      },
      {
        ']c',
        ':lua require"gitsigns".next_hunk()<CR>',
        mode = 'n',
        desc = 'Jump to [N]ext git hunk',
      },
      {
        '[c',
        ':lua require"gitsigns".prev_hunk()<CR>',
        mode = 'n',
        desc = 'Jump to [P]revious git hunk',
      },
    },
  },
  {
    'airblade/vim-gitgutter',
    enabled = false,
    event = "VeryLazy",
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
    config = function()
      vim.g.gitgutter_sign_priority = 0
    end,
  }
};
