return {
  -- Autocompletion
  "iguanacucumber/magazine.nvim",
  name = "nvim-cmp", -- Otherwise highlighting gets messed up
  dependencies = {
    -- Snippet Engine & its associated nvim-cmp source
    {
      'L3MON4D3/LuaSnip',
      build = (function()
        -- Build Step is needed for regex support in snippets
        -- This step is not supported in many windows environments
        -- Remove the below condition to re-enable on windows
        if vim.fn.has 'win32' == 1 then
          return
        end
        return 'make install_jsregexp'
      end)(),
    },
    'saadparwaiz1/cmp_luasnip',
    'onsails/lspkind.nvim',

    -- Adds LSP completion capabilities
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',

    -- Adds a number of user-friendly snippets
  },
  config = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'
    require('luasnip.loaders.from_vscode').lazy_load()
    require('luasnip.loaders.from_snipmate').lazy_load()
    luasnip.config.setup {}
    --
    local lspkind = require 'lspkind'
    local cmp_lsp_types = require 'cmp.types.lsp'
    local is_variableLikeType = function(kind)
      return kind == cmp_lsp_types.CompletionItemKind.Variable
          or kind == cmp_lsp_types.CompletionItemKind.Field
          or kind == cmp_lsp_types.CompletionItemKind.Property
          or kind == cmp_lsp_types.CompletionItemKind.Unit
          or kind == cmp_lsp_types.CompletionItemKind.Value
          or kind == cmp_lsp_types.CompletionItemKind.Constant
          -- Not exactly sure if these are variable-like. Close enough.
          or kind == cmp_lsp_types.CompletionItemKind.Enum
    end
    cmp.setup {
      formatting = {
        format = lspkind.cmp_format {
          mode = 'symbol_text', -- show only symbol annotations
          maxwidth = 50,        -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
          -- can also be a function to dynamically calculate max width such as
          -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
          ellipsis_char = '...',    -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
          show_labelDetails = true, -- show labelDetails in menu. Disabled by default

          -- The function below will be called before any actual modifications from lspkind
          -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
          before = function(entry, vim_item)
            return vim_item
          end,
          symbol_map = { Copilot = '', Supermaven = '' },
        },
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = {
        completeopt = 'menu,menuone,noinsert',
      },
      mapping = {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<C-y>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
      },
      sources = {
        { name = 'copilot' },
        { name = 'supermaven' },
        {
          name = 'nvim_lsp',
          entry_filter = function(entry, ctx)
            return cmp.lsp.CompletionItemKind.Text ~= entry:get_kind()
          end,
        },
        { name = 'luasnip' },
        { name = "vim-dadbod-completion" },
        { name = 'path' },
      },
      sorting = {
        comparators = {
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          -- cmp.config.compare.scopes,
          cmp.config.compare.score,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          --cmp.config.compare.kind,
          --kind: Entires with smaller ordinal value of 'kind' will be ranked higher.
          ---(see lsp.CompletionItemKind enum).
          ---Exceptions are that Text(1) will be ranked the lowest, and snippets be the highest.
          ---@type cmp.ComparatorFunction
          function(entry1, entry2)
            local kind1 = entry1:get_kind() --- @type lsp.CompletionItemKind | number
            local kind2 = entry2:get_kind() --- @type lsp.CompletionItemKind | number

            kind1 = kind1 == cmp_lsp_types.CompletionItemKind.Text and 100 or kind1
            kind2 = kind2 == cmp_lsp_types.CompletionItemKind.Text and 100 or kind2

            local isKind1VariableLike = is_variableLikeType(kind1)
            local isKind2VariableLike = is_variableLikeType(kind2)
            local isBothVariableLike = isKind1VariableLike and isKind2VariableLike

            if kind1 ~= kind2 and not isBothVariableLike then
              if is_variableLikeType(kind1) then
                return true
              end

              if is_variableLikeType(kind2) then
                return false
              end

              local diff = kind1 - kind2
              if diff < 0 then
                return true
              elseif diff > 0 then
                return false
              end
            end
            return nil
          end,
          -- cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },
    }
  end,
}
