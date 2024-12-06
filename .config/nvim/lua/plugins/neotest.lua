return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "HendrikThePendric/neotest-jest",
    },
    opts = function(_, opts)
      table.insert(
        opts.adapters,
        require("neotest-jest")({
          -- jestCommand = "yarn test --",
          -- jestConfigFile = "custom.jest.config.ts",
          env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        })
      )
    end,
  },
}
