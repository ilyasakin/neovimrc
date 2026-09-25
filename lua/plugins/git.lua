return {
  {
    'tpope/vim-fugitive',
    event = 'VeryLazy',
  },
  {
    -- Hunk signs, staging and inline blame (replaces vim-gitgutter + git-blame.nvim)
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '▎' },
        topdelete = { text = '▎' },
        changedelete = { text = '▎' },
        untracked = { text = '▎' },
      },
      signs_staged_enable = false,
      attach_to_untracked = true,
      current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text_pos = 'eol',
        delay = 250,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      sign_priority = 0, -- diagnostics win the sign column
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      preview_config = {
        border = 'rounded',
      },
    },
    keys = {
      {
        '<leader>hp',
        function()
          require('gitsigns').preview_hunk()
        end,
        desc = '[P]review git hunk',
      },
      {
        '<leader>hs',
        function()
          require('gitsigns').stage_hunk()
        end,
        desc = '[S]tage git hunk',
      },
      {
        '<leader>hu',
        function()
          require('gitsigns').reset_hunk()
        end,
        desc = '[U]ndo git hunk',
      },
      {
        ']c',
        function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            require('gitsigns').nav_hunk 'next'
          end
        end,
        desc = 'Jump to [N]ext git hunk',
      },
      {
        '[c',
        function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            require('gitsigns').nav_hunk 'prev'
          end
        end,
        desc = 'Jump to [P]revious git hunk',
      },
    },
  },
}
