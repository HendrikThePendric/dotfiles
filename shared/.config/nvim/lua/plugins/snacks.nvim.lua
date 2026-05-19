return {
  "folke/snacks.nvim",
  opts = {
    indent = {
      animate = {
        enabled = false,
      },
    },
    dashboard = {
      enabled = false,
    },
    lazygit = {
      enabled = false,
    },
    terminal = {
      enabled = false,
    },
    explorer = {
      enabled = false,
    },
    picker = {
      enabled = true,
      layout = {
        preset = "default",
        layout = {
          box = "horizontal",
          width = 0.95,
          height = 0.95,
          {
            box = "vertical",
            border = true,
            title = "{title} {live} {flags}",
            width = 0.3,
            min_width = 25,
            max_width = 55,
            { win = "input", height = 1, border = "bottom" },
            { win = "list", border = "none" },
          },
          { win = "preview", title = "{preview}", border = true },
        },
      },
      sources = {
        projects = {
          enabled = false,
          dev = "~/projects",
          patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "package.json", "Makefile", "pyproject.toml" },
          recent = false,
        },
      },
    },
  },
}
