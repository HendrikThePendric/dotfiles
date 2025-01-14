return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function(_, opts)
    opts.options.globalstatus = false
    -- Git branch in lualine b and moving c to b did not look nice so we just keep c and clear branch
    opts.sections.lualine_b = { "" }
    -- Clock in lualine z is not needed so we move y to z and x to y
    opts.sections.lualine_z = opts.sections.lualine_y
    opts.sections.lualine_y = opts.sections.lualine_x
    -- And clear x because that is now showing in y already
    opts.sections.lualine_x = { "" }
    return opts
  end,
}
