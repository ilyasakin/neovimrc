return {
  "jay-babu/mason-nvim-dap.nvim",
  -- Only load when nvim-dap loads
  lazy = true,
  dependencies = {
    "mason.nvim",
  },
  opts = function()
    return {
      handlers = {
        function(config)
          -- all sources with no handler get passed here

          -- Keep original functionality
          require('mason-nvim-dap').default_setup(config)
        end,

        coreclr = function(config)
          local pickers = require('telescope.pickers')
          local finders = require('telescope.finders')
          local sorters = require('telescope.sorters')
          local actions = require "telescope.actions"
          local action_state = require 'telescope.actions.state'

          -- ps -eo comm,pid,args | sed "s|$HOME|~|g"
          local input = { 'ps', '-eo', 'pid,args' }

          local opts = {
            finder = finders.new_oneshot_job(input, {}),
            sorter = sorters.get_generic_fuzzy_sorter(),
          }

          local pick = function()
            local value = nil;
            local co = coroutine.running()
            local picker = pickers.new(opts, {
              attach_mappings = function(prompt_bufnr, _)
                -- modifying what happens on selection with <CR>
                actions.select_default:replace(function()
                  -- closing picker
                  actions.close(prompt_bufnr)
                  -- the typically selection is table, depends on the entry maker
                  -- here { [1] = "one", value = "one", ordinal = "one", display = "one" }
                  -- value: original entry
                  -- ordinal: for sorting, possibly transformed value
                  -- display: for results list, possibly transformed value
                  local selection = action_state.get_selected_entry()
                  coroutine.resume(co, selection)
                end)
                -- keep default keybindings
                return true
              end,
            });
            picker:find()
            value = coroutine.yield()
            value = vim.trim(value[1])
            print(value)
            local parts = vim.split(value, ' ')
            -- return first part
            return tonumber(parts[1])
          end;

          config.adapters = {
            type = 'executable',
            command = '/Users/ilyasakin/dotfiles/bin/netcoredbg/netcoredbg',
            args = { '--interpreter=vscode' }
          }
          config.configurations = {
            {
              type = "coreclr",
              name = "attach - netcoredbg",
              request = "attach",
              processId = pick,
            }
          }
          require('mason-nvim-dap').default_setup(config)
        end,
      },
    }
  end,
}
