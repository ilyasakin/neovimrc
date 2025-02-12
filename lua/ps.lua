local M = {}

function M.pick()
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local sorters = require 'telescope.sorters'
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  local input
  if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
    input = { 'powershell', '-NoProfile', '-Command', 'Get-Process | Select-Object Id, ProcessName, CommandLine | Format-Table -AutoSize' }
  else
    input = { 'ps', '-eo', 'pid,comm,args', '--no-headers' }
  end

  local opts = {
    prompt_title = 'Select Process',
    finder = finders.new_oneshot_job(input, {}),
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        coroutine.resume(coroutine.running(), selection)
      end)
      return true
    end,
  }

  local picker = pickers.new(opts)
  picker:find()
  local value = coroutine.yield()
  value = vim.trim(value[1])
  local parts = vim.split(value, '%s+')
  return tonumber(parts[1])
end

return M 