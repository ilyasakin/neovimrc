-- keys = {
--   {
--     '<leader>gs',
--     ':G status<CR>',
--     mode = 'n',
--     desc = 'Git [S]tatus',
--   },
--   {
--     '<leader>gc',
--     ':G commit<CR>',
--     mode = 'n',
--     desc = 'Git [C]ommit',
--   },
--   {
--     '<leader>gp',
--     ':G push<CR>',
--     mode = 'n',
--     desc = 'Git [P]ush',
--   },
--   {
--     '<leader>gl',
--     ':G log<CR>',
--     mode = 'n',
--     desc = 'Git [L]og',
--   },
--   {
--     '<leader>gd',
--     ':Gvdiffsplit<CR>',
--     mode = 'n',
--     desc = 'Git [D]iff',
--   },
-- }
--

vim.api.nvim_set_keymap('n', '<leader>gs', ':G status<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gc', ':G commit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gp', ':G push<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gl', ':G log<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gd', ':Gvdiffsplit<CR>', { noremap = true, silent = true })
