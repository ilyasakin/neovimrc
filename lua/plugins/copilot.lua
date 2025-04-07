local function focus_window_with_buf(target_bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == target_bufnr then
      vim.api.nvim_set_current_win(win)
      return true
    end
  end
  return false  -- buffer not currently visible in any window
end

return {
  {
    'github/copilot.vim',
    enabled = false,
  },
  {
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      dependencies = {
        { "github/copilot.vim" },                       -- or zbirenbaum/copilot.lua
        { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
      },
      build = "make tiktoken",                          -- Only on MacOS or Linux
      opts = {
        window = {
          width = 0.25
        }
      },
      keys = {
        {
          "<leader>zc",
          function()
            if focus_window_with_buf("copilot-chat") == false then
              vim.cmd("CopilotChat")
            end
          end,
          desc = "Copilot Chat"
        }
      }
    },
  }
}
