local M = {}

function M.pick()
  local utils = require 'utils'
  local telescope = {
    pickers = utils.safe_require 'telescope.pickers',
    finders = utils.safe_require 'telescope.finders',
    sorters = utils.safe_require 'telescope.sorters',
    actions = utils.safe_require 'telescope.actions',
    state = utils.safe_require 'telescope.actions.state',
  }

  if not telescope.pickers then
    return nil
  end

  local input
  if utils.is_windows() then
    input = { 'powershell', '-NoProfile', '-Command', 'Get-Process | Select-Object Id, ProcessName, CommandLine | Format-Table -AutoSize' }
  else
    input = { 'ps', 'ax', '-o', 'pid=,comm=,args=' }
  end

  local opts = {
    prompt_title = 'Select Process',
    finder = telescope.finders.new_oneshot_job(input, {
      entry_maker = function(line)
        if not line or line == '' then
          return nil
        end
        local pid, comm, args = line:match '^%s*(%d+)%s+([^%s]+)%s+(.+)$'
        if not pid then
          return nil
        end
        pid = tonumber(pid)
        if not pid then
          return nil
        end
        return {
          value = { pid = pid, comm = comm, args = args },
          display = string.format('%7d %s %s', pid, comm, args),
          ordinal = string.format('%d %s %s', pid, comm, args),
        }
      end,
    }),
    sorter = telescope.sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr, _)
      telescope.actions.select_default:replace(function()
        telescope.actions.close(prompt_bufnr)
        local selection = telescope.state.get_selected_entry()
        if not selection then
          return
        end
        coroutine.resume(coroutine.running(), selection)
      end)
      return true
    end,
  }

  local ok, picker = pcall(telescope.pickers.new, opts)
  if not ok then
    utils.notify_error('Failed to create process picker: ' .. tostring(picker))
    return nil
  end

  local ok_find, _ = pcall(picker.find, picker)
  if not ok_find then
    utils.notify_error('Failed to show process picker')
    return nil
  end

  local value = coroutine.yield()
  if not value or not value.value or not value.value.pid then
    return nil
  end
  return value.value.pid
end

return M 