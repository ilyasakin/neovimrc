return {
  'folke/which-key.nvim',
  lazy = false,
  config = function()
    local wk = require('which-key')
    wk.setup({})
    wk.add({
      {
        mode = { "n", "v" },
        { "<leader>c", group = "[C]ode" },
        { "<leader>d", group = "[D]ocument" },
        { "<leader>g", group = "[G]it" },
        { "<leader>h", group = "Git [H]unk" },
        { "<leader>q", group = "[Q]uick" },
        { "<leader>r", group = "[R]ename" },
        { "<leader>s", group = "[S]earch" },
        { "<leader>t", group = "[T]oggle" },
        { "<leader>w", group = "[W]orkspace" },
      },
  })
  end
}

