vim.keymap.set('n', '<leader>gs', ':G status<CR>', { desc = 'Git status' })
vim.keymap.set('n', '<leader>gc', ':G commit<CR>', { desc = 'Git commit' })
vim.keymap.set('n', '<leader>gp', ':G push<CR>', { desc = 'Git push' })
vim.keymap.set('n', '<leader>gl', ':G log<CR>', { desc = 'Git log' })
vim.keymap.set('n', '<leader>gd', ':Gvdiffsplit<CR>', { desc = 'Git diff split' })

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps

-- Next error, previous error
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go { severity = severity }
  end
end

vim.keymap.set('n', ']d', diagnostic_goto(true), { desc = 'Next Diagnostic' })
vim.keymap.set('n', '[d', diagnostic_goto(false), { desc = 'Prev Diagnostic' })
vim.keymap.set('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next Error' })
vim.keymap.set('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Prev Error' })
vim.keymap.set('n', ']w', diagnostic_goto(true, 'WARN'), { desc = 'Next Warning' })
vim.keymap.set('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Prev Warning' })
vim.keymap.set('n', ']h', diagnostic_goto(true, 'HINT'), { desc = 'Next Hint' })
vim.keymap.set('n', '[h', diagnostic_goto(false, 'HINT'), { desc = 'Prev Hint' })

vim.keymap.set(
  'n',
  '<leader>f',
  vim.diagnostic.open_float,
  { desc = 'Open floating diagnostic message' }
)
vim.keymap.set('n', '<leader>e', ':Ex<CR>', { desc = 'Open [E]xplorer' })

local quickCommit = function()
  local keys = vim.api.nvim_replace_termcodes(':Git commit -m ""<Left>', false, false, true)
  vim.api.nvim_feedkeys(keys, 'n', {})
end

local quickCommitWithBranch = function()
  local branch = vim.system({ 'git', 'branch', '--show-current' }, { text = true }):wait()

  if branch.code ~= 0 then
    return
  end

  -- Remove newline from branch.stdout
  branch.stdout = string.gsub(branch.stdout, '\n', '')

  local str = ':Git commit -m "' .. branch.stdout .. ' "<Left>'
  local keys = vim.api.nvim_replace_termcodes(str, true, true, true)
  vim.api.nvim_feedkeys(keys, 'n', {})
end

vim.keymap.set('n', '<leader>qc', quickCommit, { desc = 'Quick [C]ommit' })
vim.keymap.set('n', '<leader>qb', quickCommitWithBranch, { desc = 'Quick [C]ommit with [B]ranch' })
