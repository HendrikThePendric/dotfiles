-- Starts a Neovim RPC server socket so the OpenCode agent can attach to this
-- instance and edit files in place.
--
-- Socket naming depends on the environment:
--   - Regular hosts (arch/debian): a project-scoped socket (e.g. /tmp/nvim-<repo>)
--     so several agents, each in its own project, can run side by side.
--   - Sandbox: a single static socket (NVIM_SOCKET_PATH, default /tmp/nvim.sock)
--     — one agent per sandbox.
--
-- No-op unless the agent is OpenCode; Claude Code has its own nvim integration.

local M = {}

local DEFAULT_SANDBOX_SOCKET = "/tmp/nvim.sock"

local function named_socket()
  local script = vim.fn.expand("~/.config/scripts/nvim-socket-path.sh")
  return vim.fn.system(script):gsub("\n$", "")
end

-- Returns true if the socket is free to use, removing a stale socket file first.
local function prepare_socket(path)
  local cmd = string.format("ss -lx 2>/dev/null | grep -q %s", vim.fn.shellescape(path))
  local success, _, exit_code = os.execute(cmd)
  if success and exit_code == 0 then
    return false -- already listening
  end
  if vim.fn.filereadable(path) == 1 then
    os.remove(path)
  end
  return true
end

function M.setup()
  local agent = require("util.agent")
  if agent.name() ~= "opencode" then
    return
  end

  local path
  if agent.is_sandbox() then
    path = vim.env.NVIM_SOCKET_PATH or DEFAULT_SANDBOX_SOCKET
  else
    path = named_socket()
  end

  if prepare_socket(path) then
    vim.fn.serverstart(path)
  end
end

return M
