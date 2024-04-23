local setup_lsp_handlers = function()
  -- https://www.reddit.com/r/neovim/comments/1c3iz5j/hack_truncate_long_typescript_inlay_hints
  -- Workaround for truncating long TypeScript inlay hints.
  -- TODO: Remove this if https://github.com/neovim/neovim/issues/27240 gets addressed.
  local inlay_hint_handler = vim.lsp.handlers[vim.lsp.protocol.Methods.textDocument_inlayHint]
  vim.lsp.handlers[vim.lsp.protocol.Methods.textDocument_inlayHint] = function(err, result, ctx, config)
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

  vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
      underline = {
        severity = { min = vim.diagnostic.severity.ERROR }
      },
      signs = {
        severity = { min = vim.diagnostic.severity.ERROR }
      },
      virtual_text = {
        spacing = 5,
        severity = { min = vim.diagnostic.severity.ERROR }
      },
      update_in_insert = false,
    }
  )
end

local on_attach = function(client, bufnr)
  local utils = require 'utils'

  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(bufnr, true)
  end

  utils.lsp_nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  utils.lsp_nmap('<leader>ca', function()
    vim.lsp.buf.code_action { context = { only = { 'quickfix', 'refactor', 'source' } } }
  end, '[C]ode [A]ction')

  utils.lsp_nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  utils.lsp_nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  utils.lsp_nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  utils.lsp_nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  utils.lsp_nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  utils.lsp_nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

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
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'jmederosalvarado/roslyn.nvim',
    'williamboman/mason-lspconfig.nvim',
    { 'j-hui/fidget.nvim',       opts = {} },
    'folke/neodev.nvim',
    'hrsh7th/nvim-cmp',

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
          hint = { enable = true }
          -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
          -- diagnostics = { disable = { 'missing-fields' } },
        },
      },
      tsserver = {}
    }

    -- Setup neovim lua configuration
    require('neodev').setup()

    local capabilities = vim.tbl_deep_extend("force",
      vim.lsp.protocol.make_client_capabilities(),
      require('cmp_nvim_lsp').default_capabilities()
    )
    capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
    capabilities.textDocument.completion.completionItem.snippetSupport = false

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
          capabilities = vim.tbl_deep_extend("force", capabilities, {
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

    require("roslyn").setup({
      roslyn_version = "4.9.2",
      on_attach = on_attach,
      capabilities = capabilities
    });
  end
};
