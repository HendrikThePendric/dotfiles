-- Host-specific options for macOS
-- Use dedicated pyenv virtualenv to avoid installing pynvim in every Python version
vim.g.python3_host_prog = vim.fn.expand("~/.pyenv/versions/neovim/bin/python")
