vim.api.nvim_create_user_command('DateIsoNew', function()
    require('date').iso()
end, {}) 