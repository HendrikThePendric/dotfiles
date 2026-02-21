local wk = require("which-key")

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--------------
-- TERMINAL --
--------------

-- Add custom terminal which-key group
wk.add({ {
  "<leader>z",
  group = "terminal",
  icon = "",
  mode = { "n", "v" },
} })

-- Remove LazyVim default terminal mappings
vim.keymap.del({ "n" }, "<leader>ft")
vim.keymap.del({ "n" }, "<leader>fT")
vim.keymap.del({ "n", "t" }, "<c-/>")
vim.keymap.del({ "n", "t" }, "<c-_>")

--------------
-- OPENCODE --
--------------

-- Add OpenCode which-key group
wk.add({ {
  "<leader>o",
  group = "opencode",
  icon = "󱚢 ",
  mode = { "n", "v" },
} })

--------------
-- COMMENTS --
--------------

-- Toggle comment on current line in Normal mode
vim.keymap.set("n", "<A-/>", function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  require("mini.comment").toggle_lines(line, line)
end, { silent = true, desc = "Toggle comment on current line" })

-- Toggle comment on selection in Visual mode
vim.keymap.set("v", "<A-/>", function()
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  local start_line = start_pos[2]
  local end_line = end_pos[2]

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  require("mini.comment").toggle_lines(start_line, end_line)
end, { silent = true, desc = "Toggle comment on selection" })

------------
-- POPUPS --
------------

-- Single key to dismiss ALL popups while typing
vim.keymap.set("i", "<A-Space>", function()
  -- 1. Close blink.cmp completion menu
  local blink_ok, blink = pcall(require, "blink.cmp")
  if blink_ok and blink then
    blink.hide()
  end

  -- 2. Close all floating windows (LSP hover, diagnostics, etc.)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
end, { desc = "Dismiss all popups (completion + floating windows)" })
