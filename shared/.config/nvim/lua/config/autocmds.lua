-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- This is handy for working on multiple projects in several terminal (OS) windows:
-- It ensures the CWD is always displayed, which makes it easy to distinguish between
-- the different projects
vim.api.nvim_create_autocmd({ "DirChanged" }, {
  group = vim.api.nvim_create_augroup("update_kitty_window_bar", { clear = true }),
  callback = function()
    vim.opt.title = true
    vim.opt.titlestring = string.gsub(vim.fn.getcwd(), tostring(os.getenv("HOME")), "~")
  end,
})
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    vim.opt_local.statusline = vim.opt.statusline:get()
  end
})