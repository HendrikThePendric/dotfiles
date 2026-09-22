-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- ============================================================================
-- Clipboard
-- ============================================================================
-- Sync with system clipboard. Host: wl-copy/xclip/pbcopy. Sandbox: headless with
-- no provider tools, so Neovim's built-in OSC 52 (relayed through tmux → terminal)
-- is used instead.
vim.opt.clipboard = "unnamedplus"

-- ============================================================================
-- Session Management
-- ============================================================================
-- Include localoptions in session to preserve filetype/syntax highlighting
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- ============================================================================
-- Host-specific options
-- ============================================================================
-- Source host-specific options if present
local local_opts = vim.fn.stdpath("config") .. "/lua/config/options.lua.local"
if vim.fn.filereadable(local_opts) == 1 then
  dofile(local_opts)
end

-- ============================================================================
-- RPC server
-- ============================================================================
-- Start the nvim RPC server for the OpenCode agent (no-op otherwise). Named
-- socket on regular hosts, static socket in the sandbox — see util/rpc.lua.
require("util.rpc").setup()
