return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'jay-babu/mason-nvim-dap.nvim',
      'LiadOz/nvim-dap-repl-highlights',
      'theHamsta/nvim-dap-virtual-text',
      'rcarriga/nvim-dap-ui',
    },
    lazy = true,
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
    config = function()
      local dap = require 'dap'
      local ui = require 'dapui'

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    lazy = true,
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
              processId = function()
                return require('ps').pick()
              end,
            },
          }

          require('mason-nvim-dap').default_setup(config)
        end,
      },
    },
  },
}
