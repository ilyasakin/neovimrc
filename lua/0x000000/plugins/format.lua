return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  -- Everything in opts will be passed to setup()
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      ['javascript'] = { 'prettierd', 'prettier' },
      ['javascriptreact'] = { 'prettierd', 'prettier' },
      ['typescript'] = { 'prettierd', 'prettier' },
      ['typescriptreact'] = { 'prettierd', 'prettier' },
      ['vue'] = { 'prettierd', 'prettier' },
      ['css'] = { 'prettierd', 'prettier' },
      ['scss'] = { 'prettierd', 'prettier' },
      ['less'] = { 'prettierd', 'prettier' },
      ['html'] = { 'prettierd', 'prettier' },
      ['json'] = { 'prettierd', 'prettier' },
      ['jsonc'] = { 'prettierd', 'prettier' },
      ['yaml'] = { 'prettierd', 'prettier' },
      ['markdown'] = { 'prettierd', 'prettier' },
      ['markdown.mdx'] = { 'prettierd', 'prettier' },
      ['graphql'] = { 'prettierd', 'prettier' },
      ['handlebars'] = { 'prettierd', 'prettier' },
      ['cs'] = { 'csharpier' }
    },
  },
  init = function()
    vim.api.nvim_create_user_command('Format', function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ['end'] = { args.line2, end_line:len() },
        }
      end
      require('conform').format { async = true, lsp_fallback = true, range = range }
    end, { range = true, desc = 'Format current buffer with LSP' })
  end,
}
