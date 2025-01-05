return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function(_, opts)
    opts.inactive_winbar = {
      lualine_x = { "filename" },
    }
  end,
}
