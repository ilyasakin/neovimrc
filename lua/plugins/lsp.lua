local setup_lsp_handlers = function()
  -- Configure LSP logging
  vim.lsp.set_log_level("ERROR")
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
      severity = { min = vim.diagnostic.severity.ERROR },
    },
    signs = {
      severity = { min = vim.diagnostic.severity.ERROR },
      text = {
        [vim.diagnostic.severity.ERROR] = '!',
        [vim.diagnostic.severity.WARN] = '!',
        [vim.diagnostic.severity.INFO] = 'i',
        [vim.diagnostic.severity.HINT] = '?',
      },
    },
    virtual_text = {
      spacing = 5,
      severity = { min = vim.diagnostic.severity.ERROR },
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
    if not val.kind then
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
      'rachartier/tiny-code-action.nvim'
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

      -- Get lspconfig for proper server setup
      local lspconfig = require('lspconfig')
      
      -- Configure individual servers using lspconfig
      lspconfig.clangd.setup(vim.tbl_extend('force', servers_config, {
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=never',
          '--completion-style=detailed',
          '--function-arg-placeholders',
        },
      }))

      lspconfig.gopls.setup(vim.tbl_extend('force', servers_config, {
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
      }))

      -- Function to find Python path searching parent directories 
      local function find_python_path()
        local current_dir = vim.fn.expand('%:p:h')
        local git_root = vim.fn.system('git rev-parse --show-toplevel 2>/dev/null'):gsub('\n', '')
        
        -- If not in git repo, fallback to system python
        if git_root == '' then
          return vim.fn.exepath('python3') or vim.fn.exepath('python')
        end
        
        -- Common venv directory names
        local venv_names = { 'venv', '.venv', 'env', '.env' }
        
        -- Search from current directory up to git root
        local search_dir = current_dir
        while search_dir and search_dir ~= '' and vim.fn.fnamemodify(search_dir, ':p') ~= vim.fn.fnamemodify(git_root, ':p') do
          for _, venv_name in ipairs(venv_names) do
            local venv_path = search_dir .. '/' .. venv_name
            local python_path = venv_path .. '/bin/python'
            if vim.fn.executable(python_path) == 1 then
              return python_path
            end
          end
          search_dir = vim.fn.fnamemodify(search_dir, ':h')
        end
        
        -- Check git root as well
        for _, venv_name in ipairs(venv_names) do
          local venv_path = git_root .. '/' .. venv_name
          local python_path = venv_path .. '/bin/python'
          if vim.fn.executable(python_path) == 1 then
            return python_path
          end
        end
        
        -- Fallback to system python
        return vim.fn.exepath('python3') or vim.fn.exepath('python')
      end

      lspconfig.pyright.setup(vim.tbl_extend('force', servers_config, {
        before_init = function(params, config)
          local python_path = find_python_path()
          config.settings.python.pythonPath = python_path
        end,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'openFilesOnly',
            },
          },
        },
      }))

      lspconfig.rust_analyzer.setup(vim.tbl_extend('force', servers_config, {
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
      }))

      lspconfig.html.setup(vim.tbl_extend('force', servers_config, {
        filetypes = { 'html', 'twig', 'hbs' },
      }))

      lspconfig.cssls.setup(vim.tbl_extend('force', servers_config, {
        filetypes = { 'css', 'scss', 'less', 'sass' },
      }))

      lspconfig.lua_ls.setup(vim.tbl_extend('force', servers_config, {
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
      }))

      lspconfig.prismals.setup(servers_config)

      -- Enable servers using mason-lspconfig
      local servers = {
        'clangd', 'gopls', 'pyright', 'rust_analyzer', 
        'html', 'cssls', 'lua_ls', 'prismals'
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
