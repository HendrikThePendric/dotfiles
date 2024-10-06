return {
  -- Set default colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    -- Override default moon to storm
    opts = { style = "storm" },
  },
  -- Addiotional color schemes
  { "ellisonleao/gruvbox.nvim" },
  { "gbprod/nord.nvim" },
}
