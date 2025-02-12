local M = {}

function M.pick()
  local date = os.date('%Y-%m-%dT%H:%M:%S')
  return date
end

vim.api.nvim_create_user_command('DateIsoNew', function()
  local result = M.pick()
  vim.api.nvim_put({ result }, '', true, true)
end, {})

return M 