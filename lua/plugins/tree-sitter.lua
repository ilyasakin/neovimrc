local parsers = {
  'awk',
  'bash',
  'c',
  'c_sharp',
  'cpp',
  'css',
  'csv',
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
  'markdown_inline',
  'prisma',
  'python',
  'rust',
  'scss',
  'sql',
  'swift',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'vue',
  'xml',
  'yaml',
  'zig',
}

return {
  {
    -- Highlight, edit, and navigate code (the `main` branch does not support lazy-loading)
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      -- install() is async and a no-op for installed parsers, but skip the call entirely when nothing is missing
      local installed = require('nvim-treesitter').get_installed 'parsers'
      local missing = vim.tbl_filter(function(lang)
        return not vim.list_contains(installed, lang)
      end, parsers)
      if #missing > 0 then
        require('nvim-treesitter').install(missing)
      end

      local indent_disabled = { yaml = true }

      local filetypes = { 'dap-repl' }
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
  },
  {
    'windwp/nvim-ts-autotag',
    ft = { 'html', 'xml', 'javascriptreact', 'typescriptreact', 'vue', 'svelte', 'markdown' },
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    },
  },
}
