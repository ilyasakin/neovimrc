vim.api.nvim_create_user_command('GuidNew', function()
    require('guid').new()
end, {}) 