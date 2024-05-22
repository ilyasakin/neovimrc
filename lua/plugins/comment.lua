return {
  {
    'numToStr/Comment.nvim',
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    event = 'VeryLazy',
    opts = {
      pre_hook = function()
        return vim.bo.commentstring
      end,
    },
    enabled = vim.fn.has("nvim-0.10.0") == 0,
  },
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has("nvim-0.10.0") == 1,
  }
}
