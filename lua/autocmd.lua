local window_resize_group = vim.api.nvim_create_augroup('WinResize', { clear = true })

vim.api.nvim_create_autocmd('VimResized', {
  group = window_resize_group,
  pattern = '*',
  command = 'wincmd =',
  desc = 'Automatically resize windows when the host window size changes.',
})

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
