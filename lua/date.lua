local M = {}

function M.iso()
  local date = os.date('%Y-%m-%dT%H:%M:%S')
  vim.api.nvim_put({ date }, '', true, true)
end

return M 