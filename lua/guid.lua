local M = {}

function M.new()
    local guid
    if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
        guid = vim.fn.system('powershell -command "[guid]::NewGuid().ToString()"')
    else
        guid = vim.fn.system('uuidgen')
    end
    guid = guid:gsub('[\n\r]+$', '')
    
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    
    if start_pos[2] ~= 0 and end_pos[2] ~= 0 then
        local end_col = end_pos[3]
        if vim.fn.visualmode() == 'V' then
            end_col = vim.fn.col({end_pos[2], '$'}) - 1
        end
        vim.api.nvim_buf_set_text(0, start_pos[2] - 1, start_pos[3] - 1, end_pos[2] - 1, end_col, {guid})
    else
        vim.api.nvim_put({guid}, '', true, true)
    end
end

return M 
