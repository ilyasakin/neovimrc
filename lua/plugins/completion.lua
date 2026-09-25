local Kind = vim.lsp.protocol.CompletionItemKind

-- Variable-like items (values you can reference) rank above functions, classes, keywords…
local variable_like = {
  [Kind.Variable] = true,
  [Kind.Field] = true,
  [Kind.Property] = true,
  [Kind.Unit] = true,
  [Kind.Value] = true,
  [Kind.Constant] = true,
  -- Not exactly sure if these are variable-like. Close enough.
  [Kind.Enum] = true,
}

--- Ranks variable-like kinds first, then by kind ordinal, with Text always last.
local function compare_kind(a, b)
  local kind1 = a.kind == Kind.Text and 100 or a.kind
  local kind2 = b.kind == Kind.Text and 100 or b.kind
  if kind1 == kind2 then
    return nil
  end
  local var1, var2 = variable_like[kind1], variable_like[kind2]
  if var1 and var2 then
    return nil
  end
  if var1 then
    return true
  end
  if var2 then
    return false
  end
  return kind1 < kind2
end

return {
  'saghen/blink.cmp',
  version = '1.*', -- release tags ship a prebuilt Rust fuzzy matcher
  event = 'InsertEnter',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- <C-n>/<C-p> select, <C-y> accept, <C-Space> open, <C-e> close, <C-b>/<C-f> scroll docs
    keymap = {
      preset = 'default',
      -- Tab belongs to Supermaven's inline suggestions
      ['<Tab>'] = false,
      ['<S-Tab>'] = false,
    },
    completion = {
      -- First item is selected but not inserted until accepted (was completeopt=menu,menuone,noinsert)
      list = { selection = { preselect = true, auto_insert = false } },
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      menu = { max_height = 15 },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets' },
      per_filetype = {
        lua = { inherit_defaults = true, 'lazydev' },
      },
      providers = {
        lsp = {
          -- Plain-text suggestions from servers are noise
          transform_items = function(_, items)
            return vim.tbl_filter(function(item)
              return item.kind ~= Kind.Text
            end, items)
          end,
        },
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
      },
    },
    fuzzy = {
      implementation = 'prefer_rust_with_warning',
      sorts = { 'exact', 'score', compare_kind, 'sort_text' },
    },
    cmdline = { enabled = false },
  },
}
