return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- Optional UI enhancements:
    "MeanderingProgrammer/render-markdown.nvim", -- render markdown in chat
    "echasnovski/mini.diff", -- cleaner inline diffs
  },
  event = "VeryLazy", -- Load on demand
  opts = {
    -- Leave setup empty unless customizing
    -- Default adapter is GitHub Copilot (auto-detected)
  },
  config = function(_, opts)
    -- Treesitter: Ensure markdown support for chat rendering
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "markdown",
        "markdown_inline",
      },
    })

    require("codecompanion").setup(opts)

    -- Key mappings (beautified suggested workflow)
    vim.keymap.set({ "n", "v" }, "<leader>a", "", { desc = "+ai" })
    vim.keymap.set({ "n", "v" }, "<leader>aa", ":CodeCompanionActions<CR>", { desc = "CodeCompanion: action palette" })
    vim.keymap.set({ "n", "v" }, "<leader>ac", ":CodeCompanionChat Toggle<CR>", { desc = "CodeCompanion: toggle chat" })
    vim.keymap.set("v", "<leader>aA", ":CodeCompanionChat Add<CR>", { desc = "CodeCompanion: add selection to chat" })
  end,
}
