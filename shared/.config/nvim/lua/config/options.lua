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

-- ============================================================================
-- MCP Integration
-- ============================================================================
-- Enable MCP socket for OpenCode integration
-- This creates a dynamic socket path based on project directory that external tools can connect to
if vim.fn.has('nvim') == 1 then
  -- Generate dynamic socket path using external script
  local function get_socket_path()
    local script_path = vim.fn.expand('~/.config/scripts/nvim-socket-path.sh')
    local socket_path = vim.fn.system(script_path):gsub('\n$', '')
    return socket_path
  end
  
  local socket_path = get_socket_path()
  vim.fn.serverstart(socket_path)
end
