return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        -- Confirm suggestion with <Tab> as well as <Enter>
        ["<Tab>"] = cmp.mapping.confirm({ select = true }),
      })
      opts.experimental = vim.tbl_extend("force", opts.experimental, {
        -- Disable inline preview of suggestions (these are extremely annoying)
        ghost_text = false,
      })
    end,
  },
}
