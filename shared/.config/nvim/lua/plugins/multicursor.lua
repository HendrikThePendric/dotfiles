return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")
    local wk = require("which-key")
    mc.setup()

    -- Match-based cursor addition
    vim.keymap.set({ "n", "x" }, "<leader>m", function()
      mc.matchAddCursor(1)
    end)
    vim.keymap.set({ "n", "x" }, "<leader>M", function()
      mc.matchAddCursor(-1)
    end)

    -- Toggle cursors on/off (hidden from which-key)
    vim.keymap.set({ "n", "x" }, "<c-q>", mc.toggleCursor)

    -- Which-key registration with icons
    wk.add({
      { "<leader>m", desc = "multicursor next match", icon = "󰘎 ", mode = { "n", "x" } },
      { "<leader>M", desc = "multicursor prev match", icon = "󰘎 ", mode = { "n", "x" } },
    })

    -- Keymaps that only apply when multiple cursors are active
    mc.addKeymapLayer(function(layerSet)
      -- Navigate between cursors
      layerSet({ "n", "x" }, "<left>", mc.prevCursor)
      layerSet({ "n", "x" }, "<right>", mc.nextCursor)

      -- Delete current cursor
      layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

      -- Repeat matchAddCursor with just 'm'/'M' (no leader needed)
      layerSet({ "n", "x" }, "m", function()
        mc.matchAddCursor(1)
      end)
      layerSet({ "n", "x" }, "M", function()
        mc.matchAddCursor(-1)
      end)

      -- Enable/clear cursors with escape
      layerSet("n", "<esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)
  end,
}
