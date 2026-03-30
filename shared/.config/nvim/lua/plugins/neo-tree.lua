return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    {
      "<leader>e",
      function()
        local manager = require("neo-tree.sources.manager")
        local renderer = require("neo-tree.ui.renderer")
        local state = manager.get_state("filesystem")
        local is_visible = renderer.window_exists(state)
        if is_visible then
          local winid = state.winid
          if winid and vim.api.nvim_win_is_valid(winid) and vim.api.nvim_get_current_win() == winid then
            -- Focused → close
            require("neo-tree.command").execute({ action = "close" })
          else
            -- Open but not focused → focus
            vim.api.nvim_set_current_win(winid)
          end
        else
          -- Closed → open
          require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
        end
      end,
      desc = "File Explorer",
    },
  },
}
