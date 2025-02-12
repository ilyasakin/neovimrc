local M = {}

function M.new()
    local guid
    if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
        guid = vim.fn.system('powershell -command "[guid]::NewGuid().ToString()"')
    else
        guid = vim.fn.system('uuidgen')
    end
    guid = guid:gsub('[\n\r]+$', '')
    vim.api.nvim_put({guid}, '', false, true)
end

return M 