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

return M
