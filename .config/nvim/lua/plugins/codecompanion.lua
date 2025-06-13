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
    strategies = {
      chat = {
        tools = {
          ["cmd_runner"] = { requires_approval = false },
          ["editor"] = { requires_approval = false },
          ["create_file"] = { requires_approval = false },
          ["read_file"] = { requires_approval = false },
          ["insert_edit_into_file"] = { requires_approval = false },
        },
        keymaps = {
          next_chat = {
            modes = { n = "<leader>an" },
            opts = { noremap = true, silent = true },
          },
          previous_chat = {
            modes = { n = "<leader>ap" },
            opts = { noremap = true, silent = true },
          },
        },
      },
    },
    -- Leave setup empty unless customizing
    -- Default adapter is GitHub Copilot (auto-detected)
  },
  keys = {
    { "<leader>a", "", mode = { "n", "v" }, desc = "+ai", noremap = true, silent = true },
    {
      "<leader>aa",
      ":CodeCompanionActions<CR>",
      mode = { "n", "v" },
      desc = "CodeCompanion: action palette",
      noremap = true,
      silent = true,
    },
    {
      "<leader>ac",
      ":CodeCompanionChat Toggle<CR>",
      mode = { "n", "v" },
      desc = "CodeCompanion: toggle chat",
      noremap = true,
      silent = true,
    },
    {
      "<leader>aA",
      ":CodeCompanionChat Add<CR>",
      mode = { "v" },
      desc = "CodeCompanion: add selection to chat",
      noremap = true,
      silent = true,
    },
  },
  config = function(_, opts)
    -- Treesitter: Ensure markdown support for chat rendering
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "markdown",
        "markdown_inline",
        "diff",
      },
    })

    -- Ensure mini.diff is loaded (if using LazyVim, it should be auto-loaded, but you can require it explicitly)
    pcall(require, "mini.diff")

    require("codecompanion").setup(opts)
    require("codecompanion").setup(opts)
  end,
}
