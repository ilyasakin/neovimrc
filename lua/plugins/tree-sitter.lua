return {
  -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'windwp/nvim-ts-autotag',
    'LiadOz/nvim-dap-repl-highlights'
  },
  build = ':TSUpdate',
  config = function()
    require('nvim-dap-repl-highlights').setup();
    require('nvim-treesitter.configs').setup {
      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = {
        'awk',
        'bash',
        'c',
        'cpp',
        'css',
        'csv',
        'dap_repl',
        'dockerfile',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'go',
        'gomod',
        'html',
        'javascript',
        'json',
        'kotlin',
        'lua',
        'markdown',
        'prisma',
        'python',
        'rust',
        'scss',
        'sql',
        'swift',
        'toml',
        'typescript',
        'vim',
        'vimdoc',
        'vue',
        'xml',
        'yaml',
        'zig',
      },

      -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
      auto_install = false,
      -- Install languages synchronously (only applied to `ensure_installed`)
      sync_install = false,
      -- List of parsers to ignore installing
      ignore_install = {},
      -- You can specify additional Treesitter modules here: -- For example: -- playground = {--enable = true,-- },
      modules = {},
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      autotag = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<M-space>',
        },
      },
    }
  end,
}
