-- The AI assistant plugin, selected once here rather than per-host.
-- See util/agent.lua for how the agent is chosen (AIS_AGENT in sandboxes,
-- OS detection on regular hosts).

if require("util.agent").name() == "claude" then
  return {
    "coder/claudecode.nvim",
    dependencies = {
      { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    keys = {
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", desc = "Send selection to Claude", mode = "v" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file to Claude",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer", mode = "n" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff", mode = "n" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff", mode = "n" },
    },
    lazy = false,
    opts = {
      terminal = {
        provider = "none",
      },
    },
  }
end

return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  keys = {
    { "<leader>aa", function() require("opencode").ask("@this: ", { submit = true }) end, desc = "Ask opencode…", mode = { "n", "x" } },
    { "<leader>as", function() require("opencode").select() end, desc = "Execute opencode action…", mode = { "n", "x" } },
    { "<leader>at", function() require("opencode").toggle() end, desc = "Toggle opencode", mode = { "n", "t" } },
    { "<leader>ao", function() return require("opencode").operator("@this ") end, desc = "Add range to opencode", expr = true, mode = "n" },
    { "<leader>ap", function() require("opencode").prompt() end, desc = "Prompt opencode", mode = { "n", "x" } },
    { "<leader>ac", function() require("opencode").command() end, desc = "OpenCode command", mode = "n" },
    { "<leader>au", function() require("opencode").command("session.half.page.up") end, desc = "Scroll opencode up", mode = "n" },
    { "<leader>ad", function() require("opencode").command("session.half.page.down") end, desc = "Scroll opencode down", mode = "n" },
  },
  config = function()
    vim.g.opencode_opts = {
      provider = {
        enabled = "tmux",
        tmux = {
          options = "-h",
          focus = false,
          allow_passthrough = false,
        },
      },
    }
    vim.o.autoread = true
  end,
}
