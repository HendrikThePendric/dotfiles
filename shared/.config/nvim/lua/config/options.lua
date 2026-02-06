-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- ============================================================================
-- Clipboard
-- ============================================================================
-- Sync with system clipboard (uses wl-copy on Wayland, xclip/xsel on X11)
vim.opt.clipboard = "unnamedplus"

-- ============================================================================
-- Session Management
-- ============================================================================
-- Include localoptions in session to preserve filetype/syntax highlighting
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- ============================================================================
-- Python Provider
-- ============================================================================
-- Use dedicated pyenv virtualenv to avoid installing pynvim in every Python version
vim.g.python3_host_prog = vim.fn.expand("~/.pyenv/versions/neovim/bin/python")
