return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({ dir = LazyVim.root() })
      end,
      desc = "Focus explorer NeoTree",
    },
    {
      "<leader>E",
      function()
        vim.cmd([[Neotree close]])
      end,
      desc = "Close explorer NeoTree",
    },
  },
}
