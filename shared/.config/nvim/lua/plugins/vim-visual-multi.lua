return {
  "mg979/vim-visual-multi",
  init = function()
    vim.g.VM_theme = "codedark"
  end,
  config = function()
    local wk = require("which-key")
    local vm_visual_add = function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>(VM-Visual-Add)", true, false, true), "x", true)
    end

    wk.add({
      { "<leader>m", "<Plug>(VM-Find-Under)", desc = "multicursor", icon = "󰘎 ", mode = "n" },
      { "<leader>m", group = "multicursor", icon = "󰘎 ", mode = "x" },
      {
        "<leader>ms",
        function()
          vm_visual_add()
          vim.api.nvim_input("I<Esc>")
        end,
        desc = "Add cursor at line starts",
        icon = "󰘎 ",
        mode = "x",
      },
      {
        "<leader>me",
        function()
          vm_visual_add()
          vim.api.nvim_input("A<Esc>")
        end,
        desc = "Add cursor at line ends",
        icon = "󰘎 ",
        mode = "x",
      },
    })
  end,
}
