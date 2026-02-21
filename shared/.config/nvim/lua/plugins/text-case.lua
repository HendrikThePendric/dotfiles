return {
  -- This is a fork with a fix for the visual mode bug
  -- https://github.com/johmsalas/text-case.nvim/pull/191
  "ruicsh/text-case.nvim",
  lazy = false,
  config = function()
    local textcase = require("textcase")
    local wk = require("which-key")

    textcase.setup({
      default_keymappings_enabled = false,
    })

    -- Create which-key group for <leader>T
    wk.add({
      { "<leader>T", group = "text-case", icon = " ", mode = { "n", "x" } },
    })

    -- Define case conversion functions with custom key mappings
    local cases = {
      { key = "u", func = "to_upper_case", desc = "to UPPER CASE" },
      { key = "l", func = "to_lower_case", desc = "to lower case" },
      { key = "s", func = "to_snake_case", desc = "to snake_case" },
      { key = "d", func = "to_dash_case", desc = "to dash-case" },
      { key = "t", func = "to_title_dash_case", desc = "to Title-Dash-Case" },
      { key = "c", func = "to_constant_case", desc = "to CONSTANT_CASE" },
      { key = "o", func = "to_dot_case", desc = "to dot.case" },
      { key = "m", func = "to_comma_case", desc = "to comma,case" },
      { key = "p", func = "to_phrase_case", desc = "to phrase case" },
      { key = "a", func = "to_camel_case", desc = "to camelCase" },
      { key = "P", func = "to_pascal_case", desc = "to PascalCase" },
      { key = "T", func = "to_title_case", desc = "to Title Case" },
      { key = "h", func = "to_path_case", desc = "to path/case" },
      { key = "U", func = "to_upper_phrase_case", desc = "to UPPER PHRASE CASE" },
      { key = "L", func = "to_lower_phrase_case", desc = "to lower phrase case" },
    }

    -- Create keymaps for each case
    for _, case in ipairs(cases) do
      vim.keymap.set({ "n", "x" }, "<leader>T" .. case.key, function()
        textcase.current_word(case.func)
      end, { desc = case.desc })
    end
  end,
  cmd = { "Subs", "TextCaseStartReplacingCommand" },
}
