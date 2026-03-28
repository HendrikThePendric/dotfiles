-- Neovim RPC project server
-- Starts a Unix domain socket named after the current project (git repo or directory).
-- This allows external tools (e.g. OpenCode) to attach to the running Neovim instance
-- via a stable, project-scoped socket path like /tmp/nvim-<projectname>.

local M = {}

function M.setup()
  if vim.fn.has("nvim") ~= 1 then
    return
  end

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

  if prepare_socket(socket_path) then
    vim.fn.serverstart(socket_path)
  end
end

return M
