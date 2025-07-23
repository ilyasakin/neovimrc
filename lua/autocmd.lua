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


-- Auto-reload buffers when files change externally
local autoread_group = vim.api.nvim_create_augroup('AutoRead', { clear = true })

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  group = autoread_group,
  pattern = '*',
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd('checktime')
    end
  end,
  desc = 'Check for file changes when focus is gained or cursor is held',
})
