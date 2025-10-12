return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  keys = {
    { "<leader>a",  nil,                              desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        desc = "Send to Claude",     mode = "v" },
    { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>",     desc = "Add file",           ft = { "netrw" }, },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Deny diff" },
    { "<C-,>",      "<cmd>ClaudeCodeFocus<cr>",       desc = "Claude Code",        mode = { "n", "x" } },
  },
  opts = {
    diff_opts = {
      keep_terminal_focus = true
    },
    terminal = {
      provider = "snacks",
      snacks_win_opts = {
        position = "float",
        width = 0.9,
        height = 0.9,
        border = "rounded",
        keys = {
          claude_hide = {
            "<C-,>",
            function(self) self:hide() end,
            mode = "t",
            desc = "Hide"
          }
        }
      }
    }
  }
}
