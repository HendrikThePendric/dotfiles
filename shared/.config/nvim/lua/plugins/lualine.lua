return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function(_, opts)
    opts.options.globalstatus = false

    -- Custom component for multicursor status
    local function multicursor_status()
      local ok, mc = pcall(require, "multicursor-nvim")
      if ok and mc.hasCursors() then
        return "󰘎"
      end
      return ""
    end

    -- Git branch only in sandboxes. On the host the branch shows in the tmux
    -- status bar instead, so we keep lualine lean; in a sandbox each tmux window
    -- is a different branch, so the branch belongs in nvim here.
    opts.sections.lualine_b = {
      {
        "branch",
        cond = function()
          return vim.env.IS_SANDBOX ~= nil
        end,
        separator = { right = "" },
      },
      {
        multicursor_status,
        color = { bg = "#fab387", fg = "#11111b" },
        separator = { right = "" },
      },
    }
    -- Clock in lualine z is not needed so we move y to z and x to y
    opts.sections.lualine_z = opts.sections.lualine_y
    opts.sections.lualine_y = opts.sections.lualine_x
    -- And clear x because that is now showing in y already
    opts.sections.lualine_x = { "" }
    return opts
  end,
}
