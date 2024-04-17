return {
  "zbirenbaum/copilot-cmp",
  enabled = false,
  config = function()
    vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
    require("copilot_cmp").setup()
  end
}
