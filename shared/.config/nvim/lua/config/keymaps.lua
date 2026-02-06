local wk = require("which-key")

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--------------
-- TERMINAL --
--------------

-- Add custom terminal which-key group
wk.add({{
    "<leader>z",
    group = "Terminal",
    icon = "",
    mode = { "n", "v" }
}})

-- Remove LazyVim default terminal mappings
vim.keymap.del({"n"}, "<leader>ft")
vim.keymap.del({"n"}, "<leader>fT")
vim.keymap.del({"n", "t"}, "<c-/>")
vim.keymap.del({"n", "t"}, "<c-_>")

--------------
-- OPENCODE --
--------------

-- Add OpenCode which-key group
wk.add({{
    "<leader>o",
    group = "OpenCode",
    icon = "󱚢 ",
    mode = { "n", "v" }
}})

