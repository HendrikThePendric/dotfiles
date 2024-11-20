return {
  -- Set default colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
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
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "moon", -- auto, main, moon, or dawn
      dark_variant = "moon", -- main, moon, or dawn
    },
  },
}
