return {
  'numToStr/Comment.nvim',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring'
  },
  event = 'VeryLazy',
  opts = {
    pre_hook = function()
      return vim.bo.commentstring
    end,
  }
}
