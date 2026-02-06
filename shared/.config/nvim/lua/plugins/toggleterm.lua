return {
  "akinsho/toggleterm.nvim",
  enabled = false,
  version = "*",
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    open_mapping = false,
    float_opts = {
      winblend = 0,
      width = function()
        return math.ceil(vim.o.columns * 0.8)
      end,
      height = function()
        return math.ceil(vim.o.lines * 0.8)
      end,
      border = {
        { "╭", "ToggleTermFloatBorder" },
        { "─", "ToggleTermFloatBorder" },
        { "╮", "ToggleTermFloatBorder" },
        { "│", "ToggleTermFloatBorder" },
        { "╯", "ToggleTermFloatBorder" },
        { "─", "ToggleTermFloatBorder" },
        { "╰", "ToggleTermFloatBorder" },
        { "│", "ToggleTermFloatBorder" },
      },
    },
  },
  config = function(_, opts)
    -- Set ToggleTerm-specific highlight BEFORE setup
    vim.api.nvim_set_hl(0, "ToggleTermFloatBorder", {
      fg = "#a6e3a1",
    })
    vim.api.nvim_set_hl(0, "ToggleTermBorder", {
      fg = "#a6e3a1",
    })

    require("toggleterm").setup(opts)

    local terminal_module = require("toggleterm.terminal")
    local Terminal = terminal_module.Terminal

    -- ===============
    -- === HELPERS ===
    -- ===============

    -- Get all terminals of a specific direction
    local get_terminals_by_direction = function(direction)
      local result = {}
      local all = terminal_module.get_all() -- Use cached module

      for _, term in pairs(all) do
        if term.direction == direction then
          table.insert(result, term)
        end
      end

      table.sort(result, function(a, b)
        return a.id < b.id
      end)
      return result
    end

    -- Check if any terminal of a direction is open
    local is_direction_visible = function(direction)
      local terms = get_terminals_by_direction(direction)
      for _, term in ipairs(terms) do
        if term:is_open() then
          return true
        end
      end
      return false
    end

    -- Open all terminals of a direction
    local open_all_of_direction = function(direction)
      if not direction then
        return
      end
      local terms = get_terminals_by_direction(direction)
      for _, term in ipairs(terms) do
        if not term:is_open() then
          term:open()
        end
      end
    end

    -- Close all terminals of a direction
    local close_all_of_direction = function(direction)
      if not direction then
        return
      end
      local terms = get_terminals_by_direction(direction)
      for _, term in ipairs(terms) do
        if term:is_open() then
          term:close()
        end
      end
    end

    local get_current_terminal = function()
      local current_buffer = vim.api.nvim_get_current_buf()
      return terminal_module.find(function(term)
        return term.bufnr == current_buffer
      end)
    end

    -- ==============
    -- === FLOATS ===
    -- ==============

    -- Float terminals (always independent)
    local toggle_float = function()
      local floats = get_terminals_by_direction("float")

      if #floats == 0 then
        -- No floats exist, create first one
        local term = Terminal:new({
          direction = "float",
        })
        term:toggle()
        return
      end

      -- Find any visible float
      local visible_float = nil
      for _, term in ipairs(floats) do
        if term:is_open() then
          visible_float = term
          break
        end
      end

      if visible_float then
        -- Hide the visible float
        visible_float:close()
      else
        -- No floats visible, show the most recent one (last in list)
        local last_float = floats[#floats]
        last_float:open()
        last_float:focus()
        vim.defer_fn(function()
          if vim.bo.buftype == "terminal" then
            vim.cmd("startinsert")
          end
        end, 100)
      end
    end

    local new_float = function()
      local term = Terminal:new({
        direction = "float",
      })
      term:toggle()
    end

    -- ==============
    -- === PANELS ===
    -- ==============
    local opposite_directions = {
      horizontal = "vertical",
      vertical = "horizontal",
      float = nil, -- Floats don't have opposites
    }

    -- Toggle panel (bottom or right)
    local toggle_panel = function(direction)
      local opposite_direction = opposite_directions[direction]

      if is_direction_visible(direction) then
        -- Panel is visible, hide it
        close_all_of_direction(direction)
      else
        -- Panel is hidden, show it (with mutual exclusion)
        close_all_of_direction(opposite_direction)
        local terms = get_terminals_by_direction(direction)
        local main = terms[1]

        if not main then
          main = Terminal:new({
            direction = direction,
          })
          main:open()
        else
          for _, term in ipairs(terms) do
            if not term:is_open() then
              term:open()
            end
          end
        end

        main:focus()

        vim.defer_fn(function()
          if vim.bo.buftype == "terminal" then
            vim.cmd("startinsert")
          end
        end, 100)
      end
    end

    -- Create new terminal in panel (with split)
    local new_in_panel = function(direction)
      local opposite_direction = opposite_directions[direction]

      -- Ensure mutual exclusion
      close_all_of_direction(opposite_direction)

      local panel_terminals = get_terminals_by_direction(direction)

      if #panel_terminals == 0 then
        -- Create first terminal in this panel
        local term = Terminal:new({
          direction = direction,
        })
        term:toggle()
        return term
      end

      -- Ensure panel is visible
      local last_term = nil
      if not is_direction_visible(direction) then
        for _, term in ipairs(panel_terminals) do
          if not term:is_open() then
            term:open()
          end
          last_term = term
        end
      end

      -- Focus last open terminal so ToggleTerm splits from it
      if last_term then
        last_term:focus()
      end

      -- Create new terminal (ToggleTerm will handle the split)
      local new_term = Terminal:new({
        direction = direction,
      })
      new_term:toggle()

      return new_term
    end

    local toggle_bottom = function()
      toggle_panel("horizontal")
    end
    local new_bottom = function()
      new_in_panel("horizontal")
    end

    local toggle_right = function()
      toggle_panel("vertical")
    end
    local new_right = function()
      new_in_panel("vertical")
    end

    -- ================
    -- TERMINAL PICKER
    -- ================

    local terminal_picker = function()
      local all = terminal_module.get_all() -- Use cached module
      local term_list = {}

      for _, term in pairs(all) do
        table.insert(term_list, term)
      end

      table.sort(term_list, function(a, b)
        return a.id < b.id
      end)

      if #term_list == 0 then
        vim.notify("No terminals", vim.log.levels.WARN)
        return
      end

      local items = {}
      for _, term in ipairs(term_list) do
        local status = term:is_open() and "●" or "○"
        local status_text = term:is_open() and "(open)" or "(closed)"

        local title = ""
        if term.bufnr and vim.api.nvim_buf_is_valid(term.bufnr) then
          local ok, term_title = pcall(vim.api.nvim_buf_get_var, term.bufnr, "term_title")
          if ok and term_title and term_title ~= "" then
            title = term_title:gsub("%s*;#toggleterm#%d+$", "")
            title = title:gsub("^%s+", ""):gsub("%s+$", "")
            if title ~= "" and title ~= "term" and title ~= "toggleterm" then
              title = " | " .. title
            end
          end
        end

        items[#items + 1] = {
          value = term,
          display = string.format("%s ID:%d %s %s%s", status, term.id, term.direction, status_text, title),
        }
      end

      vim.ui.select(items, {
        prompt = "Select terminal:",
        format_item = function(item)
          return item.display
        end,
      }, function(choice)
        if choice then
          local term = choice.value

          if term.direction == "float" then
            term:open()
          else
            -- Handle mutual exclusion for panels
            close_all_of_direction(opposite_directions[term.direction])
            open_all_of_direction(term.direction)

            term:focus()
            vim.defer_fn(function()
              if vim.bo.buftype == "terminal" then
                vim.cmd("startinsert")
              end
            end, 100)
          end
        end
      end)
    end

    -- ==============================
    -- === TERMINAL MODE KEYBINDS ===
    -- ==============================

    local hide_current = function()
      local term = get_current_terminal()

      if term then
        if term.direction == "float" then
          term:toggle() -- For floats, toggle hides it
        else
          toggle_panel(term.direction) -- For panels, toggle the group
        end
      else
        vim.cmd("bdelete!")
      end
    end

    local delete_current = function()
      local term = get_current_terminal()

      if term then
        term:shutdown() -- Properly kill the terminal process
      else
        vim.cmd("bdelete!")
      end
    end

    -- ======================
    -- KEYBINDS
    -- ======================

    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, {
        desc = "Terminal: " .. desc,
      })
    end

    map("<leader>zf", toggle_float, "Toggle floating terminal")
    map("<leader>znf", new_float, "New floating terminal")
    map("<leader>zb", toggle_bottom, "Toggle bottom terminals")
    map("<leader>znb", new_bottom, "New bottom terminal")
    map("<leader>zr", toggle_right, "Toggle right terminals")
    map("<leader>znr", new_right, "New right terminal")
    map("<leader>zz", toggle_bottom, "Focus/toggle main terminal")
    map("<leader>zp", terminal_picker, "Terminal picker")

    vim.keymap.set("t", "<C-\\>", delete_current, {
      desc = "Exit current terminal",
    })
    vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", {
      desc = "Exit to Neovim normal mode",
    })

    -- Wait 500ms for LazyVim to finish setting up keymaps
    -- This is a hack to override the Snacks.terminal default keybinds
    vim.defer_fn(function()
      pcall(vim.keymap.del, { "n", "t" }, "<C-/>")
      pcall(vim.keymap.del, { "n", "t" }, "<C-_>")

      vim.keymap.set("t", "<C-/>", hide_current, {
        desc = "Hide current terminal",
        nowait = true, -- Don't wait for other mappings
      })
      vim.keymap.set("n", "<C-/>", toggle_bottom, {
        desc = "Focus/toggle main terminal",
        nowait = true, -- Don't wait for other mappings
      })
      vim.keymap.set("t", "<C-_>", hide_current, {
        desc = "Hide current terminal",
        nowait = true,
      })
    end, 500)

    -- ======================
    -- DEBUG COMMAND (use cached module)
    -- ======================

    map("<leader>zdd", function()
      print("=== DEBUG ===")
      for _, direction in ipairs({ "float", "horizontal", "vertical" }) do
        local terms = get_terminals_by_direction(direction)
        print(
          string.format("%s: %d terminals, visible: %s", direction, #terms, tostring(is_direction_visible(direction)))
        )
        for _, term in ipairs(terms) do
          print(string.format("  ID:%d open:%s", term.id, tostring(term:is_open())))
        end
      end
    end, "Debug terminal state")
  end,
}
