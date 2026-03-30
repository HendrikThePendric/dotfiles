return {
  "folke/snacks.nvim",
  opts = {
    styles = {
      lazygit = {
        width = 0.999,
        height = 0.999,
      },
    },
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
