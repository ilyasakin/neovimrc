vim.fn.sign_define('DiagnosticSignError', { text = '!', texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn', { text = '!', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInfo', { text = 'i', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint', { text = '?', texthl = 'DiagnosticSignHint' })

vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DiagnosticError' })
vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DiagnosticInfo' })
vim.fn.sign_define('DapStopped', { text = '', texthl = 'Constant', linehl = 'debugPC' })
vim.fn.sign_define('DapBreakpointRejected', { text = '' })
