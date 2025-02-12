local M = {}
local wk = require('which-key')

M.lsp_nmap = function(keys, func, desc)
  if desc then
    desc = 'LSP: ' .. desc
  end

  wk.add({
    { keys, func, desc = desc, mode = 'n' }
  })
end

function M.notify_error(msg, opts)
  opts = opts or {}
  vim.notify(msg, vim.log.levels.ERROR, {
    title = opts.title or 'Error',
    timeout = opts.timeout or 5000,
  })
end

function M.notify_info(msg, opts)
  opts = opts or {}
  vim.notify(msg, vim.log.levels.INFO, {
    title = opts.title or 'Info',
    timeout = opts.timeout or 3000,
  })
end

function M.safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    M.notify_error('Failed to load module: ' .. module)
    return nil
  end
  return result
end

function M.is_windows()
  return vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
end

return M
