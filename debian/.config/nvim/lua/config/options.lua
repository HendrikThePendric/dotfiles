-- Host-specific options for Debian
-- Use system python3 for Neovim Python provider
vim.g.python3_host_prog = "/usr/bin/python3"
-- Start the Neovim RPC project server so OpenCode can attach to this instance
require("util.nvim_rpc_project_server").setup()
