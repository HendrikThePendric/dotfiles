return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")
    local wk = require("which-key")
    mc.setup()

    -- Custom cursor color
    vim.api.nvim_set_hl(0, "MultiCursorCursor", { fg = "#eba0ac", reverse = true })

    -- Match-based cursor addition (normal mode only)
    vim.keymap.set("n", "<leader>m", function()
      mc.matchAddCursor(1)
    end)
    vim.keymap.set("n", "<leader>M", function()
      mc.matchAddCursor(-1)
    end)

    -- Visual mode: line start/end cursor addition
    vim.keymap.set("x", "<leader>mm", function()
      mc.matchAddCursor(1)
    end)
    vim.keymap.set("x", "<leader>mM", function()
      mc.matchAddCursor(-1)
    end)
    vim.keymap.set("x", "<leader>ma", function()
      mc.appendVisual()
      vim.schedule(function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      end)
    end)
    vim.keymap.set("x", "<leader>mi", function()
      mc.insertVisual()
      vim.schedule(function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      end)
    end)

    -- Toggle cursors on/off (hidden from which-key)
    vim.keymap.set({ "n", "x" }, "<c-q>", mc.toggleCursor)

    -- Which-key registration with icons
    wk.add({
      { "<leader>m", desc = "multicursor next match", icon = "󰘎 ", mode = "n" },
      { "<leader>M", desc = "multicursor prev match", icon = "󰘎 ", mode = "n" },
      { "<leader>m", group = "multicursor", icon = "󰘎 ", mode = "x" },
      { "<leader>ma", desc = "append to line ends", icon = "󰘎 ", mode = "x" },
      { "<leader>mi", desc = "insert at line starts", icon = "󰘎 ", mode = "x" },
      { "<leader>mm", desc = "multicursor next match", icon = "󰘎 ", mode = "x" },
      { "<leader>mM", desc = "multicursor prev match", icon = "󰘎 ", mode = "x" },
    })

    -- Keymaps that only apply when multiple cursors are active
    mc.addKeymapLayer(function(layerSet)
      -- Navigate between cursors
      layerSet({ "n", "x" }, "<A-left>", mc.prevCursor)
      layerSet({ "n", "x" }, "<A-right>", mc.nextCursor)

      -- Delete current cursor
      layerSet({ "n", "x" }, "<A-x>", mc.deleteCursor)

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
