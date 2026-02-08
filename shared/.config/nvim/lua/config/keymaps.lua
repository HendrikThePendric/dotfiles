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
  group = "Terminal",
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
  group = "OpenCode",
  icon = "󱚢 ",
  mode = { "n", "v" },
} })

--------------
-- COMMENTS --
--------------

-- Toggle comment on current line in Normal mode
vim.keymap.set("n", "<c-/>", function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  require("mini.comment").toggle_lines(line, line)
end, { silent = true, desc = "Toggle comment on current line" })

-- Toggle comment on selection in Visual mode
vim.keymap.set("v", "<c-/>", function()
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  local start_line = start_pos[2]
  local end_line = end_pos[2]

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  require("mini.comment").toggle_lines(start_line, end_line)
end, { silent = true, desc = "Toggle comment on selection" })
