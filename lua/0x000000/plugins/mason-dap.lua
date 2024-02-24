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
              processId = 64513
            }
          }
          require('mason-nvim-dap').default_setup(config)
        end,
      },
    }
  end,
}
