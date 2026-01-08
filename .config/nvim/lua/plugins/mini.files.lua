return {
  "nvim-mini/mini.files",
  keys = {
    {
      "<leader>fM",
      function()
        require("mini.files").open(LazyVim.root(), true)
      end,
      desc = "Open mini.files (root)",
    },
  },
  opts = {
    mappings = {
      go_in = "<Right>",
      go_out = "<Left>",
    },
    windows = {
      width_preview = 60,
      width_nofocus = 30,
      width_focus = 30,
    },
  },
}
