local setup_lsp_handlers = function()
  -- Configure LSP logging
  vim.lsp.set_log_level("ERROR")
  local log_path = vim.fn.stdpath("log") .. "/lsp.log"
  vim.lsp.set_log_level("ERROR")
  if vim.fn.filereadable(log_path) == 1 then
    os.remove(log_path)
  end

  -- https://www.reddit.com/r/neovim/comments/1c3iz5j/hack_truncate_long_typescript_inlay_hints
  -- Workaround for truncating long TypeScript inlay hints.
  -- TODO: Remove this if https://github.com/neovim/neovim/issues/27240 gets addressed.
  local inlay_hint_handler = vim.lsp.handlers[vim.lsp.protocol.Methods.textDocument_inlayHint]
  vim.lsp.handlers[vim.lsp.protocol.Methods.textDocument_inlayHint] = function(
      err,
      result,
      ctx,
      config
  )
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if client and client.name == 'typescript-tools' then
      result = vim.iter.map(function(hint)
        local label = hint.label ---@type string
        if label:len() >= 30 then
          label = label:sub(1, 29) .. ellipsis
        end
        hint.label = label
        return hint
      end, result)
    end

    inlay_hint_handler(err, result, ctx, config)
  end

  -- Optimize diagnostic updates
  vim.lsp.handlers['textDocument/publishDiagnostics'] =
      vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
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
          texthl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
            [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
            [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
            [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
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
    elseif val.kind == 'report' then
      progress[client_id] = {
        title = progress[client_id].title,
        message = val.message,
        percentage = val.percentage,
        spinner = progress[client_id].spinner + 1,
      }
    elseif val.kind == 'end' then
      progress[client_id] = nil
    end
  end

  vim.lsp.handlers['$/progress'] = progress_handler
end

local on_attach = function(client, bufnr)
  client.server_capabilities.semanticTokensProvider = nil

  local utils = require 'utils'

  if client.server_capabilities.inlayHintProvider then
    local enable_inlay_hints = {
      typescript = true,
      javascript = true,
      typescriptreact = true,
      javascriptreact = true,
      rust = true,
    }
    if enable_inlay_hints[vim.bo[bufnr].filetype] then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end

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
      'seblj/roslyn.nvim',
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim',       opts = {} },
      'folke/neodev.nvim',
      "iguanacucumber/magazine.nvim",
      'rachartier/tiny-code-action.nvim',
      'https://gitlab.com/schrieveslaach/sonarlint.nvim'
    },
    config = function()
      setup_lsp_handlers()
      require('mason').setup()
      require('mason-lspconfig').setup()

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. They will be passed to
      --  the `settings` field of the server config. You must look up that documentation yourself.
      --
      --  If you want to override the default filetypes that your language server will attach to you can
      --  define the property 'filetypes' to the map in question.
      local servers = {
        clangd = {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--header-insertion=never',
            '--completion-style=detailed',
            '--function-arg-placeholders',
          },
        },
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
        pyright = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = 'openFilesOnly',
          },
        },
        rust_analyzer = {
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
        html = { filetypes = { 'html', 'twig', 'hbs' } },
        cssls = { filetypes = { 'css', 'scss', 'less', 'sass' } },
        lua_ls = {
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
        prismals = {},
      }

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

      -- Ensure the servers above are installed
      local mason_lspconfig = require 'mason-lspconfig'
      local server_list = vim.tbl_keys(servers)

      mason_lspconfig.setup {
        ensure_installed = server_list,
      }

      local lspconfig = require 'lspconfig'

      mason_lspconfig.setup_handlers {
        function(server_name)
          lspconfig[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
          }
        end,
        cssls = function()
          require('lspconfig').cssls.setup {
            capabilities = vim.tbl_deep_extend('force', capabilities, {
              textDocument = {
                completion = {
                  completionItem = {
                    snippetSupport = true,
                  },
                },
              },
            }),
            on_attach = on_attach,
            settings = servers.cssls,
            filetypes = servers.cssls.filetypes,
          }
        end,
      }

      require('roslyn').setup {
        config = {
          capabilities = capabilities,
          on_attach = on_attach,
          filetypes = { 'cs' },
          settings = {
            ["csharp|background_analysis"] = {
              dotnet_analyzer_diagnostics_scope = "openFiles",
              dotnet_compiler_diagnostics_scope = "fullSolution",
            },
          },
        },
      }

      -- require('sonarlint').setup({
      --   server = {
      --     cmd = {
      --       'sonarlint-language-server',
      --       -- Ensure that sonarlint-language-server uses stdio channel
      --       '-stdio',
      --       '-analyzers',
      --       vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjs.jar"),
      --       vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarlintomnisharp.jar"),
      --     }
      --   },
      --   filetypes = {
      --     'javascript',
      --     'javascriptreact',
      --     'typescript',
      --     'typescriptreact',
      --     'cs'
      --   }
      -- })
    end,
  },
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
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
