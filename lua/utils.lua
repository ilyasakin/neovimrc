local M = {}
local wk = require 'which-key'

function M.map(mode, keys, func, desc, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  opts.desc = desc

  if type(func) == 'string' then
    vim.keymap.set(mode, keys, func, opts)
  else
    wk.register({
      [keys] = { func, desc },
    }, {
      mode = mode,
      silent = opts.silent,
      noremap = opts.noremap ~= false,
      buffer = opts.buffer,
    })
  end
end

M.nmap = function(keys, func, desc, opts)
  M.map('n', keys, func, desc, opts)
end

M.vmap = function(keys, func, desc, opts)
  M.map('v', keys, func, desc, opts)
end

M.imap = function(keys, func, desc, opts)
  M.map('i', keys, func, desc, opts)
end

M.lsp_nmap = function(keys, func, desc, opts)
  opts = opts or {}
  opts.buffer = true
  M.nmap(keys, func, 'LSP: ' .. desc, opts)
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

function M.get_os_command(commands)
  if M.is_windows() then
    return commands.windows
  end
  return commands.unix
end

return M
