local setup_lsp_handlers = function()
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
    })
end

local function enable_full_semantic_tokens(client)
  -- NOTE: Super hacky... Don't know if I like that we set a random variable on the client
  -- Seems to work though
  if client.is_hacked then
    return
  end
  client.is_hacked = true

  -- let the runtime know the server can do semanticTokens/full now
  client.server_capabilities = vim.tbl_deep_extend('force', client.server_capabilities, {
    semanticTokensProvider = {
      full = true,
    },
  })

  -- monkey patch the request proxy
  local request_inner = client.request
  client.request = function(method, params, handler, req_bufnr)
    if method ~= vim.lsp.protocol.Methods.textDocument_semanticTokens_full then
      return request_inner(method, params, handler)
    end

    local function find_buf_by_uri(search_uri)
      local bufs = vim.api.nvim_list_bufs()
      for _, buf in ipairs(bufs) do
        local name = vim.api.nvim_buf_get_name(buf)
        local uri = 'file://' .. name
        if uri == search_uri then
          return buf
        end
      end
    end

    local target_bufnr = find_buf_by_uri(params.textDocument.uri)
    local line_count = vim.api.nvim_buf_line_count(target_bufnr)
    local last_line = vim.api.nvim_buf_get_lines(target_bufnr, line_count - 1, line_count, true)[1]

    return request_inner('textDocument/semanticTokens/range', {
      textDocument = params.textDocument,
      range = {
        ['start'] = {
          line = 0,
          character = 0,
        },
        ['end'] = {
          line = line_count - 1,
          character = string.len(last_line) - 1,
        },
      },
    }, handler, req_bufnr)
  end
end

local on_attach = function(client, bufnr)
  local utils = require 'utils'
  enable_full_semantic_tokens(client)

  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true)
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

  -- See `:help K` for why this keymap
  utils.lsp_nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  utils.lsp_nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
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
      { 'j-hui/fidget.nvim', opts = {} },
      'folke/neodev.nvim',
      'hrsh7th/nvim-cmp',
      'nvim-java/nvim-java',
      'rachartier/tiny-code-action.nvim',
    },
    config = function()
      require('java').setup()
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
        clangd = {},
        gopls = {},
        pyright = {},
        rust_analyzer = {},
        html = { filetypes = { 'html', 'twig', 'hbs' } },
        cssls = { filetypes = { 'css', 'scss', 'less', 'sass' } },
        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            hint = { enable = true },
            -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
          },
        },
        prismals = {},
        jdtls = {},
      }

      -- Setup neovim lua configuration
      require('neodev').setup()

      local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('cmp_nvim_lsp').default_capabilities()
      )
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
      -- capabilities.textDocument.completion.completionItem.snippetSupport = false

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
            ['csharp|inlay_hints'] = {
              csharp_enable_inlay_hints_for_implicit_object_creation = true,
              csharp_enable_inlay_hints_for_implicit_variable_types = true,
              csharp_enable_inlay_hints_for_lambda_parameter_types = true,
              csharp_enable_inlay_hints_for_types = true,
              dotnet_enable_inlay_hints_for_indexer_parameters = true,
              dotnet_enable_inlay_hints_for_literal_parameters = true,
              dotnet_enable_inlay_hints_for_object_creation_parameters = true,
              dotnet_enable_inlay_hints_for_other_parameters = true,
              dotnet_enable_inlay_hints_for_parameters = true,
              dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
              dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
              dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
            },
            ['csharp|code_lens'] = {
              dotnet_enable_references_code_lens = true,
            },
          },
        },
      }
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
      require('tiny-code-action').setup()
    end,
  },
}
