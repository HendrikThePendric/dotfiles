return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  keys = {
    { "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, desc = "Ask opencode…", mode = { "n", "x" } },
    { "<leader>os", function() require("opencode").select() end, desc = "Execute opencode action…", mode = { "n", "x" } },
    { "<leader>ot", function() require("opencode").toggle() end, desc = "Toggle opencode", mode = { "n", "t" } },
    { "<leader>oo", function() return require("opencode").operator("@this ") end, desc = "Add range to opencode", expr = true, mode = "n" },
    { "<leader>op", function() require("opencode").prompt() end, desc = "Prompt opencode", mode = { "n", "x" } },
    { "<leader>oc", function() require("opencode").command() end, desc = "OpenCode command", mode = "n" },
    { "<leader>ou", function() require("opencode").command("session.half.page.up") end, desc = "Scroll opencode up", mode = "n" },
    { "<leader>od", function() require("opencode").command("session.half.page.down") end, desc = "Scroll opencode down", mode = "n" },
  },
  config = function()
    vim.g.opencode_opts = {
      provider = {
        enabled = "tmux",
        tmux = {
          options = "-h", -- horizontal split
          focus = false, -- keep focus in Neovim
          allow_passthrough = false, -- prevent OSC escape sequence leakage
        },
      },
    }
    vim.o.autoread = true
  end,
}