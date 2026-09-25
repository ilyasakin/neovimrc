-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fn.getcwd()
  local current_dir = current_file == '' and cwd or vim.fn.fnamemodify(current_file, ':h')

  local git_root = vim.fs.root(current_dir, '.git')
  if not git_root then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Telescope live_grep in git root
local function live_grep_git_root()
  require('telescope.builtin').live_grep {
    search_dirs = { find_git_root() },
  }
end

local function builtin(picker, opts)
  return function()
    require('telescope.builtin')[picker](opts)
  end
end

return {
  'nvim-telescope/telescope.nvim',
  cmd = { 'Telescope', 'LiveGrepGitRoot' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
  },
  keys = {
    { '<leader>?', builtin 'oldfiles', desc = '[?] Find recently opened files' },
    { '<leader><space>', builtin 'buffers', desc = '[ ] Find existing buffers' },
    {
      '<leader>/',
      function()
        require('telescope.builtin').current_buffer_fuzzy_find(
          require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          }
        )
      end,
      desc = '[/] Fuzzily search in current buffer',
    },
    {
      '<leader>s/',
      builtin('live_grep', { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }),
      desc = '[S]earch [/] in Open Files',
    },
    { '<leader>ss', builtin 'builtin', desc = '[S]earch [S]elect Telescope' },
    { '<leader>gf', builtin 'git_files', desc = 'Search [G]it [F]iles' },
    { '<leader>sf', builtin 'find_files', desc = '[S]earch [F]iles' },
    { '<leader>sh', builtin 'help_tags', desc = '[S]earch [H]elp' },
    { '<leader>sw', builtin 'grep_string', desc = '[S]earch current [W]ord' },
    { '<leader>sg', builtin 'live_grep', desc = '[S]earch by [G]rep' },
    { '<leader>sG', live_grep_git_root, desc = '[S]earch by [G]rep on Git Root' },
    { '<leader>sd', builtin 'diagnostics', desc = '[S]earch [D]iagnostics' },
    { '<leader>sr', builtin 'resume', desc = '[S]earch [R]esume' },
  },

  config = function()
    require('telescope').setup {
      defaults = {
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-d>'] = false,
          },
        },
        path_display = {
          'filename_first',
        },
      },
    }

    -- Enable telescope fzf native, if installed
    pcall(require('telescope').load_extension, 'fzf')

    vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})
  end,
}
