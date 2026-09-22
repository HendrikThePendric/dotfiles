-- Single source of truth for "which agent, and are we in a sandbox".
--
-- Sandboxes declare their agent via the AIS_AGENT image ENV (claude|opencode).
-- Regular hosts have no AIS_AGENT: Claude Code on macOS, OpenCode on Linux.

local M = {}

function M.is_sandbox()
  return vim.env.IS_SANDBOX ~= nil
end

function M.name()
  if vim.env.AIS_AGENT then
    return vim.env.AIS_AGENT
  end
  return vim.loop.os_uname().sysname == "Darwin" and "claude" or "opencode"
end

return M
