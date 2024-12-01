return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- The following are optional:
    { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
  },
  opts = {
    -- Refer to: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
    strategies = { -- Change the adapters as required
      chat = { adapter = "ollama" },
      inline = { adapter = "ollama" },
      agent = { adapter = "ollama" },
    },
  },
}
