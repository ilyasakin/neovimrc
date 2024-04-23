vim.keymap.set('v', 'p', [["_dP]])

-- This probably won't get me cancelled.
vim.keymap.set('i', '<C-c>', '<Esc>')

vim.keymap.set('n', 'Q', '<nop>')

vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Disable -root of all the evil- arrow keys
vim.keymap.set({ 'n', 'i', 'v' }, '<Up>', '<Nop>', { silent = true })
vim.keymap.set({ 'n', 'i', 'v' }, '<Down>', '<Nop>', { silent = true })
vim.keymap.set({ 'n', 'i', 'v' }, '<Left>', '<Nop>', { silent = true })
vim.keymap.set({ 'n', 'i', 'v' }, '<Right>', '<Nop>', { silent = true })
