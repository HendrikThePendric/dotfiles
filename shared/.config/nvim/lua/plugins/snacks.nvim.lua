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
      enabled = true,
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
        explorer = {
          enabled = true,
          hidden = true,
          auto_close = false,
          win = {
            list = {
              keys = {
                ["O"] = {
                  { "pick_win", "jump" },
                  mode = { "n", "i" },
                },
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
        local explorer_pickers = Snacks.picker.get({
          source = "explorer",
        })
        if #explorer_pickers == 0 then
          Snacks.picker.explorer()
        elseif explorer_pickers[1]:is_focused() then
          explorer_pickers[1]:close()
        else
          explorer_pickers[1]:focus()
        end
      end,
      desc = "File explorer",
    }, -- {
    --     "<leader>fp",
    --     function()
    --         Snacks.picker.projects()
    --     end,
    --     desc = "Projects"
    -- }
  },
}
