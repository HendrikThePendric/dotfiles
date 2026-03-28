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
          options = "-h",         -- horizontal split
          focus = false,          -- keep focus in Neovim
          allow_passthrough = false,
        },
      },
    }
    vim.o.autoread = true
  end,
}
