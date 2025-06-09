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
    explorer = { enabled = true }, -- NOT HERE!
    picker = {
      enabled = true,
      sources = {
        explorer = { -- HERE!
          enabled = true,
          hidden = true,
          auto_close = false,
          win = {
            list = {
              keys = {
                ["O"] = { { "pick_win", "jump" }, mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  keys = {
    {
      "<leader>e",
      function()
        local explorer_pickers = Snacks.picker.get({ source = "explorer" })
        if #explorer_pickers == 0 then
          Snacks.picker.explorer()
        elseif explorer_pickers[1]:is_focused() then
          explorer_pickers[1]:close()
        else
          explorer_pickers[1]:focus()
        end
      end,
      desc = "File explorer",
    },
  },
}
