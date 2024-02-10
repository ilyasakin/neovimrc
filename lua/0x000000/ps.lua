local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')

local input = { 'ps', 'aux' }

local opts = {
	finder = finders.new_oneshot_job(input),
	sorter = sorters.get_generic_fuzzy_sorter(),
}

vim.api.nvim_create_user_command('Ps',
	function()
		local picker = pickers.new(opts);
		picker:find()
	end,
	{})
