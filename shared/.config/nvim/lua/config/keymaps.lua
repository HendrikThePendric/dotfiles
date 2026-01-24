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
    icon = ""
}})

-- Remove LazyVim default terminal mappings
vim.keymap.del({"n"}, "<leader>ft")
vim.keymap.del({"n"}, "<leader>fT")
vim.keymap.del({"n", "t"}, "<c-/>")
vim.keymap.del({"n", "t"}, "<c-_>")

--------------
-- AI ASSISTANT --
--------------

-- Add AI assistant which-key group
wk.add({{
    "<leader>a",
    group = "AI Assistant",
    icon = "󱚢 "
}})

