return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'jay-babu/mason-nvim-dap.nvim',
      'LiadOz/nvim-dap-repl-highlights',
      'theHamsta/nvim-dap-virtual-text',
      'rcarriga/nvim-dap-ui',
    },
    keys = {
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        desc = 'Debug: Continue',
      },
      {
        '<leader>dn',
        function()
          require('dap').step_over()
        end,
        desc = 'Debug: Step over',
      },
      {
        '<leader>di',
        function()
          require('dap').step_into()
        end,
        desc = 'Debug: Step into',
      },
      {
        '<leader>do',
        function()
          require('dap').step_out()
        end,
        desc = 'Debug: Step out',
      },
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Debug: Toggle breakpoint',
      },
      {
        '<leader>dp',
        function()
          require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
        end,
        desc = 'Set log point',
      },
      {
        '<leader>dr',
        function()
          require('dap').repl.toggle()
        end,
        desc = 'Toggle REPL',
      },
      {
        '<leader>dz',
        function()
          require('dap').set_exception_breakpoints()
        end,
        desc = 'Set exception breakpoints',
      },
    },
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },

    opts = {},
    keys = {
      {
        '<leader>du',
        function()
          require('dapui').toggle { layout = 1 }
        end,
        desc = 'Toggle UI sidebar',
      },
      {
        '<leader>dU',
        function()
          require('dapui').toggle {}
        end,
        desc = 'Toggle UI',
      },
      {
        '<leader>dt',
        function()
          require('dapui').toggle { layout = 2 }
        end,
        desc = 'Toggle console',
      },
      {
        '<M-k>',
        function()
          require('dapui').eval()
        end,
        desc = 'Evaluate expression',
        mode = { 'n', 'v' },
      },
    },
  },
  {
    'jay-babu/mason-nvim-dap.nvim',
    -- Only load when nvim-dap loads
    lazy = true,
    dependencies = {
      'williamboman/mason.nvim',
      'mfussenegger/nvim-dap',
    },
    opts = {
      ensure_installed = { 'stylua', 'jq' },
      handlers = {
        function(config)
          -- all sources with no handler get passed here

          -- Keep original functionality
          require('mason-nvim-dap').default_setup(config)
        end,

        coreclr = function(config)
          local pickers = require 'telescope.pickers'
          local finders = require 'telescope.finders'
          local sorters = require 'telescope.sorters'
          local actions = require 'telescope.actions'
          local action_state = require 'telescope.actions.state'

          -- ps -eo comm,pid,args | sed "s|$HOME|~|g"
          local input = { 'ps', '-eo', 'pid,args' }

          local opts = {
            finder = finders.new_oneshot_job(input, {}),
            sorter = sorters.get_generic_fuzzy_sorter(),
          }

          local pick = function()
            local value = nil
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
            })
            picker:find()
            value = coroutine.yield()
            value = vim.trim(value[1])
            local parts = vim.split(value, ' ')
            -- return first part
            return tonumber(parts[1])
          end

          config.adapters = {
            type = 'executable',
            command = '/Users/ilyasakin/dotfiles/bin/netcoredbg/netcoredbg',
            args = { '--interpreter=vscode' },
          }

          config.configurations = {
            {
              type = 'coreclr',
              name = 'attach - netcoredbg',
              request = 'attach',
              processId = pick,
            },
          }

          require('mason-nvim-dap').default_setup(config)
        end,
      },
    },
  },
}
