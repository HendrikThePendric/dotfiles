return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
    diagnostics = {
      virtual_text = false,
    },
    servers = {
      vtsls = {
        settings = {
          vtsls = {
            autoUseWorkspaceTsdk = false,
          },
        },
      },
    },
  },
}
