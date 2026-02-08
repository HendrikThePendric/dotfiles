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
      ["*"] = {
        keys = {
          {
            "K",
            function()
              local params = vim.lsp.util.make_position_params(0, "utf-16")
              local has_hover = false

              vim.lsp.buf_request_all(0, "textDocument/hover", params, function(responses)
                for _, response in pairs(responses or {}) do
                  if not response.err and response.result and response.result.contents then
                    local lines = vim.lsp.util.convert_input_to_markdown_lines(response.result.contents)
                    if lines and #lines > 0 then
                      has_hover = true
                      vim.lsp.util.open_floating_preview(lines, "markdown", {
                        border = "rounded",
                      })
                      return
                    end
                  end
                end

                if not has_hover then
                  vim.notify("No information available", vim.log.levels.INFO)
                end
              end)
            end,
            desc = "Smart hover",
          },
        },
      },
    },
  },
}
