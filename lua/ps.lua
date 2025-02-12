local M = {}

function M.pick()
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local sorters = require 'telescope.sorters'
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  local input = { 'ps', '-eo', 'pid,args' }

  local opts = {
    finder = finders.new_oneshot_job(input, {}),
    sorter = sorters.get_generic_fuzzy_sorter(),
  }

  local value = nil
  local co = coroutine.running()
  local picker = pickers.new(opts, {
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        coroutine.resume(co, selection)
      end)
      return true
    end,
  })
  picker:find()
  value = coroutine.yield()
  value = vim.trim(value[1])
  local parts = vim.split(value, ' ')
  return tonumber(parts[1])
end

return M 