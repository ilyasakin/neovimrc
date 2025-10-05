local setup_lsp_handlers = function()
  -- Configure LSP logging
  vim.lsp.log.set_level("ERROR")
  local log_path = vim.fn.stdpath("log") .. "/lsp.log"
  if vim.fn.filereadable(log_path) == 1 then
    os.remove(log_path)
  end

  -- Override diagnostic handler to prevent bufstate nil errors
  local original_handler = vim.lsp.handlers['textDocument/publishDiagnostics']
  vim.lsp.handlers['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
    if not result then return end
    local bufnr = vim.uri_to_bufnr(result.uri)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    return original_handler(err, result, ctx, config)
  end

  -- Inlay hints are disabled

  -- Configure diagnostics
  vim.diagnostic.config({
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
  })

  -- Debounce progress updates
  local progress = {}
  local function progress_handler(_, result, ctx)
    local client_id = ctx.client_id
    local client = vim.lsp.get_client_by_id(client_id)
    if not client then
      return
    end

    local val = result.value
    if not val or not val.kind then
      return
    end

    if val.kind == 'begin' then
      progress[client_id] = {
        title = val.title,
        message = val.message,
        percentage = val.percentage,
        spinner = 1,
      }
    elseif progress[client_id] and val.kind == 'report' then
      progress[client_id] = {
        title = progress[client_id].title,
        message = val.message,
        percentage = val.percentage,
        spinner = progress[client_id].spinner + 1,
      }
    elseif progress[client_id] and val.kind == 'end' then
      progress[client_id] = nil
    end
  end

  vim.lsp.handlers['$/progress'] = progress_handler
end

local on_attach = function(client, bufnr)
  client.server_capabilities.semanticTokensProvider = nil

  local utils = require 'utils'

  -- Inlay hints are disabled globally

  utils.lsp_nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  utils.lsp_nmap('<leader>ca', require('tiny-code-action').code_action, '[C]ode [A]ction')

  utils.lsp_nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  utils.lsp_nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  utils.lsp_nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  utils.lsp_nmap(
    '<leader>D',
    require('telescope.builtin').lsp_type_definitions,
    'Type [D]efinition'
  )
  utils.lsp_nmap(
    '<leader>ds',
    require('telescope.builtin').lsp_document_symbols,
    '[D]ocument [S]ymbols'
  )
  utils.lsp_nmap(
    '<leader>ws',
    require('telescope.builtin').lsp_dynamic_workspace_symbols,
    '[W]orkspace [S]ymbols'
  )

  utils.lsp_nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  utils.lsp_nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  utils.lsp_nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  utils.lsp_nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  utils.lsp_nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  utils.lsp_nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')
end

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim',       opts = {} },
      'folke/neodev.nvim',
      "iguanacucumber/magazine.nvim",
      'rachartier/tiny-code-action.nvim',
      'b0o/schemastore.nvim'
    },
    config = function()
      setup_lsp_handlers()
      require('mason').setup({
        registries = {
          "github:mason-org/mason-registry",
          "github:Crashdummyy/mason-registry",
        }
      })
      require('mason-lspconfig').setup()

      -- Setup neovim lua configuration
      require('neodev').setup()

      -- Optimize capabilities
      local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('cmp_nvim_lsp').default_capabilities(),
        {
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
        }
      )

      -- Configure servers individually with proper initialization
      local servers_config = {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Use vim.lsp.config for server setup (new API in Neovim 0.11+)

      -- Configure individual servers using vim.lsp.config
      vim.lsp.config.clangd = vim.tbl_extend('force', servers_config, {
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=never',
          '--completion-style=detailed',
          '--function-arg-placeholders',
        },
      })
      vim.lsp.enable('clangd')

      vim.lsp.config.gopls = vim.tbl_extend('force', servers_config, {
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
      vim.lsp.enable('gopls')

      vim.lsp.config.pyright = servers_config
      vim.lsp.enable('pyright')

      vim.lsp.config.rust_analyzer = vim.tbl_extend('force', servers_config, {
        settings = {
          ['rust-analyzer'] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              runBuildScripts = true,
            },
            checkOnSave = {
              allFeatures = true,
              command = 'clippy',
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
      vim.lsp.enable('rust_analyzer')

      vim.lsp.config.html = vim.tbl_extend('force', servers_config, {
        filetypes = { 'html', 'twig', 'hbs' },
      })
      vim.lsp.enable('html')

      vim.lsp.config.cssls = vim.tbl_extend('force', servers_config, {
        filetypes = { 'css', 'scss', 'less', 'sass' },
      })
      vim.lsp.enable('cssls')

      vim.lsp.config.lua_ls = vim.tbl_extend('force', servers_config, {
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
              library = {
                '${3rd}/luv/library',
                unpack(vim.api.nvim_get_runtime_file('', true)),
              },
            },
            completion = {
              callSnippet = 'Replace',
            },
            telemetry = { enable = false },
            hint = { enable = true },
          },
        },
      })
      vim.lsp.enable('lua_ls')

      vim.lsp.config.prismals = servers_config
      vim.lsp.enable('prismals')

      -- Configure additional common LSP servers
      vim.lsp.config.jsonls = vim.tbl_extend('force', servers_config, {
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      })
      vim.lsp.enable('jsonls')

      vim.lsp.config.yamlls = vim.tbl_extend('force', servers_config, {
        settings = {
          yaml = {
            schemaStore = {
              enable = false,
              url = '',
            },
            schemas = require('schemastore').yaml.schemas(),
          },
        },
      })
      vim.lsp.enable('yamlls')

      vim.lsp.config.bashls = servers_config
      vim.lsp.enable('bashls')
      vim.lsp.config.dockerls = servers_config
      vim.lsp.enable('dockerls')

      -- Swift LSP configuration (SourceKit-LSP)
      vim.lsp.config.sourcekit = vim.tbl_extend('force', servers_config, {
        cmd = { 'sourcekit-lsp' },
        filetypes = { 'swift', 'c', 'cpp', 'objective-c', 'objective-cpp' },
        root_dir = function(filename, _)
          -- Use vim.fs.find for root pattern detection
          local markers = {'buildServer.json', '*.xcodeproj', '*.xcworkspace', 'Package.swift', 'compile_commands.json', '.git'}
          local found = vim.fs.find(markers, {
            path = filename,
            upward = true,
            stop = vim.fn.expand('~')
          })[1]
          if found then
            return vim.fs.dirname(found)
          end
          -- Fallback to git ancestor or current dir
          local git_dir = vim.fs.find('.git', {
            path = filename,
            upward = true,
            stop = vim.fn.expand('~')
          })[1]
          if git_dir then
            return vim.fs.dirname(git_dir)
          end
          return vim.fs.dirname(filename)
        end,
        capabilities = vim.tbl_deep_extend('force', capabilities, {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        }),
        settings = {},
      })
      vim.lsp.enable('sourcekit')

      -- Kotlin LSP configuration
      vim.lsp.config.kotlin_language_server = servers_config
      vim.lsp.enable('kotlin_language_server')

      -- Enable servers using mason-lspconfig
      local servers = {
        'clangd', 'gopls', 'pyright', 'rust_analyzer',
        'html', 'cssls', 'lua_ls', 'prismals',
        'jsonls', 'yamlls', 'bashls', 'dockerls',
        'kotlin_language_server'
      }

      local mason_lspconfig = require 'mason-lspconfig'
      mason_lspconfig.setup {
        ensure_installed = servers,
      }

      -- Set up autocmd for LSP attach to ensure keymaps are registered
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client then
            on_attach(client, event.buf)
          end
        end,
      })
    end,
  },
  {
    'seblyng/roslyn.nvim',
    ft = 'cs',
    opts = {
      config = {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "fullSolution",
          },
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
          },
        },
      },
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
      require('typescript-tools').setup({
        on_attach = on_attach,
        capabilities = capabilities,
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
      })
    end,
  },
  {
    'rachartier/tiny-code-action.nvim',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope.nvim' },
    },
    event = 'LspAttach',
    config = function()
      require('tiny-code-action').setup({});
    end,
  },
}
