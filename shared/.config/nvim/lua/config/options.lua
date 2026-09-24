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

-- Sandbox: yanks are forwarded to the host over OSC 52, but pastes come from the
-- last yank inside this Neovim. Reading the host clipboard over OSC 52 would ask
-- tmux, which answers from its own paste buffer (get-clipboard=buffer) — stale
-- text or a timeout. Paste from outside the sandbox with Cmd+V instead.
if require("util.agent").is_sandbox() then
  local osc52 = require("vim.ui.clipboard.osc52")
  local last = {}
  local function copy(reg)
    local forward = osc52.copy(reg)
    return function(lines, regtype)
      last[reg] = { lines, regtype }
      forward(lines, regtype)
    end
  end
  local function paste(reg)
    return function()
      return last[reg] or { {}, "v" }
    end
  end
  vim.g.clipboard = {
    name = "osc52-copy-local-paste",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
  }
end

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
