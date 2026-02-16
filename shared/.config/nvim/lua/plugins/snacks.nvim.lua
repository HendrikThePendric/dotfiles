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
          on_show = function(picker)
            local show = false
            local gap = 1
            local clamp_width = function(value)
              return math.max(20, math.min(100, value))
            end
            --
            local position = picker.resolved_layout.layout.position
            local rel = picker.layout.root
            local update = function(win) ---@param win snacks.win
              local border = win:border_size().left + win:border_size().right
              win.opts.row = vim.api.nvim_win_get_position(rel.win)[1]
              win.opts.height = 0.8
              if position == "left" then
                win.opts.col = vim.api.nvim_win_get_width(rel.win) + gap
                win.opts.width = clamp_width(vim.o.columns - border - win.opts.col)
              end
              if position == "right" then
                win.opts.col = -vim.api.nvim_win_get_width(rel.win) - gap
                win.opts.width = clamp_width(vim.o.columns - border + win.opts.col)
              end
              win:update()
            end
            local preview_win = Snacks.win.new({
              relative = "editor",
              external = false,
              focusable = false,
              border = "rounded",
              backdrop = false,
              show = show,
              bo = {
                filetype = "snacks_float_preview",
                buftype = "nofile",
                buflisted = false,
                swapfile = false,
                undofile = false,
              },
              on_win = function(win)
                update(win)
                picker:show_preview()
              end,
            })
            rel:on("WinLeave", function()
              vim.schedule(function()
                if not picker:is_focused() then
                  picker.preview.win:close()
                end
              end)
            end)
            rel:on("WinResized", function()
              update(preview_win)
            end)
            picker.preview.win = preview_win
            picker.main = preview_win.win
          end,
          on_close = function(picker)
            picker.preview.win:close()
          end,
          layout = {
            preset = "sidebar",
            preview = false,
          },
          actions = {
            toggle_preview = function(picker)
              picker.preview.win:toggle()
            end,
          },
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
