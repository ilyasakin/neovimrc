return {
  -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  dependencies = {
    'windwp/nvim-ts-autotag',
    'LiadOz/nvim-dap-repl-highlights',
  },
  config = function()
    local parsers = {
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
    }

    require('nvim-dap-repl-highlights').setup()
    require('nvim-treesitter').install(parsers)

    require('nvim-ts-autotag').setup({
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    })

    local indent_disabled = { yaml = true }

    local filetypes = {}
    for _, lang in ipairs(parsers) do
      vim.list_extend(filetypes, vim.treesitter.language.get_filetypes(lang))
    end

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
      pattern = filetypes,
      callback = function(args)
        if vim.api.nvim_buf_line_count(args.buf) > 10000 then
          return
        end
        if not pcall(vim.treesitter.start, args.buf) then
          return
        end
        local ft = vim.bo[args.buf].filetype
        if not indent_disabled[ft] then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
