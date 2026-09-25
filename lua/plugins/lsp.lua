local setup_diagnostics = function()
  -- Configure LSP logging
  vim.lsp.log.set_level 'ERROR'
  local log_path = vim.fn.stdpath 'log' .. '/lsp.log'
  if vim.fn.filereadable(log_path) == 1 then
    os.remove(log_path)
  end

  -- Inlay hints are disabled

  vim.diagnostic.config {
    underline = {
      severity = { min = vim.diagnostic.severity.WARN },
    },
    signs = {
      severity = { min = vim.diagnostic.severity.WARN },
      text = {
        [vim.diagnostic.severity.ERROR] = '!',
        [vim.diagnostic.severity.WARN] = '!',
        [vim.diagnostic.severity.INFO] = 'i',
        [vim.diagnostic.severity.HINT] = '?',
      },
    },
    virtual_text = {
      spacing = 5,
      severity = { min = vim.diagnostic.severity.WARN },
    },
    update_in_insert = false,
    severity_sort = true,
    float = {
      header = '',
      source = 'if_many',
      border = 'rounded',
      max_width = 100,
    },
  }
end

-- Buffer-local LSP keymaps; runs on every LspAttach (including roslyn and typescript-tools)
local on_attach = function(client, bufnr)
  client.server_capabilities.semanticTokensProvider = nil

  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, silent = true, desc = 'LSP: ' .. desc })
  end
  -- Telescope is required on use so attaching a server doesn't load it
  local telescope = function(picker)
    return function()
      require('telescope.builtin')[picker]()
    end
  end

  map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  map('<leader>ca', function()
    require('tiny-code-action').code_action()
  end, '[C]ode [A]ction')

  map('gd', telescope 'lsp_definitions', '[G]oto [D]efinition')
  map('gr', telescope 'lsp_references', '[G]oto [R]eferences')
  map('gI', telescope 'lsp_implementations', '[G]oto [I]mplementation')
  map('<leader>D', telescope 'lsp_type_definitions', 'Type [D]efinition')
  map('<leader>ds', telescope 'lsp_document_symbols', '[D]ocument [S]ymbols')
  map('<leader>ws', telescope 'lsp_dynamic_workspace_symbols', '[W]orkspace [S]ymbols')

  map('K', vim.lsp.buf.hover, 'Hover Documentation')
  map('gK', vim.lsp.buf.signature_help, 'Signature Documentation') -- <C-k> is pane navigation

  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  map('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  map('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  map('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')
end

-- Capabilities shared by every server, on top of what blink.cmp advertises
local capabilities = function()
  return vim.tbl_deep_extend('force', require('blink.cmp').get_lsp_capabilities({}, true), {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = false,
      },
    },
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      },
      completion = {
        completionItem = {
          snippetSupport = false,
          commitCharactersSupport = false,
          deprecatedSupport = false,
          preselectSupport = false,
        },
      },
    },
  })
end

-- Servers started through vim.lsp.enable; mason-lspconfig installs any that are missing
local servers = {
  'clangd',
  'gopls',
  'pyright',
  'rust_analyzer',
  'html',
  'cssls',
  'lua_ls',
  'prismals',
  'jsonls',
  'yamlls',
  'bashls',
  'dockerls',
  'kotlin_language_server',
}

-- Non-LSP tools installed through Mason (formatters used by conform)
local tools = { 'stylua', 'csharpier' }

return {
  {
    'mason-org/mason.nvim',
    cmd = 'Mason',
    opts = {
      registries = {
        'github:mason-org/mason-registry',
        'github:Crashdummyy/mason-registry',
      },
    },
    config = function(_, opts)
      require('mason').setup(opts)
      local registry = require 'mason-registry'
      registry.refresh(function()
        for _, name in ipairs(tools) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end)
    end,
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    config = function()
      setup_diagnostics()

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client then
            on_attach(client, event.buf)
          end
        end,
      })

      vim.lsp.config('*', { capabilities = capabilities() })

      vim.lsp.config('clangd', {
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=never',
          '--completion-style=detailed',
          '--function-arg-placeholders=1',
        },
      })

      vim.lsp.config('gopls', {
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
            usePlaceholders = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      vim.lsp.config('rust_analyzer', {
        settings = {
          ['rust-analyzer'] = {
            cargo = {
              features = 'all',
              buildScripts = { enable = true },
            },
            checkOnSave = true,
            check = {
              command = 'clippy',
              features = 'all',
              extraArgs = { '--no-deps' },
            },
            procMacro = {
              enable = true,
              ignored = {
                ['async-trait'] = { 'async_trait' },
                ['napi-derive'] = { 'napi' },
                ['async-recursion'] = { 'async_recursion' },
              },
            },
          },
        },
      })

      vim.lsp.config('html', {
        filetypes = { 'html', 'twig', 'hbs' },
      })

      vim.lsp.config('cssls', {
        filetypes = { 'css', 'scss', 'less', 'sass' },
      })

      -- Neovim runtime/plugin types come from lazydev.nvim
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            completion = { callSnippet = 'Replace' },
            telemetry = { enable = false },
            hint = { enable = true },
          },
        },
      })

      -- SchemaStore's catalog is large; only load it when the server actually starts
      vim.lsp.config('jsonls', {
        settings = { json = { validate = { enable = true } } },
        before_init = function(_, config)
          config.settings.json.schemas = require('schemastore').json.schemas()
        end,
      })

      vim.lsp.config('yamlls', {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = '' },
          },
        },
        before_init = function(_, config)
          config.settings.yaml.schemas = require('schemastore').yaml.schemas()
        end,
      })

      -- SourceKit-LSP (from Xcode) handles Swift/Objective-C; C and C++ stay with clangd
      vim.lsp.config('sourcekit', {
        filetypes = { 'swift', 'objc', 'objcpp' },
      })

      require('mason-lspconfig').setup {
        ensure_installed = servers,
        automatic_enable = false, -- enabled explicitly below; roslyn/ts are handled by their plugins
      }
      vim.lsp.enable(servers)
      vim.lsp.enable 'sourcekit'
    end,
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'b0o/schemastore.nvim',
    lazy = true,
  },
  {
    'seblyng/roslyn.nvim',
    ft = 'cs',
    init = function()
      vim.lsp.config('roslyn', {
        settings = {
          ['csharp|background_analysis'] = {
            dotnet_analyzer_diagnostics_scope = 'openFiles',
            dotnet_compiler_diagnostics_scope = 'fullSolution',
          },
          ['csharp|inlay_hints'] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
          },
          ['csharp|code_lens'] = {
            dotnet_enable_references_code_lens = true,
          },
        },
      })
    end,
    opts = {
      filewatching = 'auto',
      broad_search = false,
      lock_target = false,
    },
  },
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    config = function()
      require('typescript-tools').setup {
        capabilities = capabilities(),
        settings = {
          separate_diagnostic_server = true,
          publish_diagnostic_on = 'insert_leave',
          expose_as_code_action = {},
          tsserver_path = nil,
          tsserver_plugins = {},
          tsserver_max_memory = 'auto',
          tsserver_format_options = {},
          tsserver_file_preferences = {
            includeInlayParameterNameHints = 'none',
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = false,
            includeInlayVariableTypeHints = false,
            includeInlayVariableTypeHintsWhenTypeMatchesName = false,
            includeInlayPropertyDeclarationTypeHints = false,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayEnumMemberValueHints = false,
          },
        },
      }
    end,
  },
  {
    'rachartier/tiny-code-action.nvim',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope.nvim' },
    },
    lazy = true,
    opts = {},
  },
}
