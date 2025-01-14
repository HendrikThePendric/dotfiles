return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "s1n7ax/nvim-window-picker",
    config = function()
      require("window-picker").setup({
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          -- filter using buffer options
          bo = {
            -- if the file type is one of following, the window will be ignored
            filetype = { "neo-tree", "neo-tree-popup", "notify" },
            -- if the buffer type is one of following, the window will be ignored
            buftype = { "terminal", "quickfix" },
          },
        },
        highlights = {
          enabled = true,
          statusline = {
            focused = {
              fg = "#cdd6f4",
              bg = "#f38ba8",
              bold = true,
            },
            unfocused = {
              fg = "#cdd6f4",
              bg = "#a6e3a1",
              bold = true,
            },
          },
          winbar = {
            focused = {
              fg = "#cdd6f4",
              bg = "#f38ba8",
              bold = true,
            },
            unfocused = {
              fg = "#cdd6f4",
              bg = "#a6e3a1",
              bold = true,
            },
          },
        },
      })
    end,
  },
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
