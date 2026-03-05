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
-- Only starts server if one doesn't already exist for the current project
if vim.fn.has("nvim") == 1 then
  -- Generate dynamic socket path using external script
  local function get_socket_path()
    local script_path = vim.fn.expand("~/.config/scripts/nvim-socket-path.sh")
    local socket_path = vim.fn.system(script_path):gsub("\n$", "")
    return socket_path
  end

  local socket_path = get_socket_path()

  -- Check if socket is already in use and clean up stale sockets if needed
  local function prepare_socket(path)
    -- Use ss to check if socket is actively listening
    local cmd = string.format("ss -lx 2>/dev/null | grep -q %s", vim.fn.shellescape(path))
    local success, _, exit_code = os.execute(cmd)

    -- If socket is actively listening (grep found it), don't start another server
    if success and exit_code == 0 then
      return false -- Socket in use, don't start
    end

    -- Socket not in ss output, but file might still exist (stale socket)
    -- Remove stale socket file if it exists
    if vim.fn.filereadable(path) == 1 then
      os.remove(path)
    end

    return true -- Socket ready for use
  end

  -- Only start server if socket is not already in use
  if prepare_socket(socket_path) then
    vim.fn.serverstart(socket_path)
  end
end
