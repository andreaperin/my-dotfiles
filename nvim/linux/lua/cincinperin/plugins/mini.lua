-- mini.icons ------------------------------------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.icons" })
  require("mini.icons").setup()
end)

-- mini.pick (fuzzy finder) ------------------------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.pick" })
  require("mini.pick").setup()

  vim.keymap.set("n", "<leader>ff", function() MiniPick.builtin.files() end, { desc = "Find Files" })
  vim.keymap.set("n", "<leader>fg", function() MiniPick.builtin.grep_live() end, { desc = "Live Grep" })
  vim.keymap.set("n", "<leader>fb", function() MiniPick.builtin.buffers() end, { desc = "Find Buffers" })
  vim.keymap.set("n", "<leader>fh", function() MiniPick.builtin.help() end, { desc = "Help Tags" })
end)

-- mini.files (file explorer) -----------------------------------------------------------------

-- `now`, not `later`: mini.starter's "Config" action opens mini.files immediately on
-- click, and the dashboard itself is shown before the `later` queue necessarily drains.
MiniMisc.now(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.files" })
  require("mini.files").setup({
    mappings = { go_in_plus = "<CR>" },
  })

  local show_hidden_files = false

  local filter__show_hidden_files = function(fs_entry)
    return true
  end

  local filter__hide_hidden_files = function(fs_entry)
    return not vim.startswith(fs_entry.name, ".")
  end

  local toggle_hidden_files = function()
    show_hidden_files = not show_hidden_files
    local new_filter = show_hidden_files and filter__show_hidden_files or filter__hide_hidden_files

    MiniFiles.refresh({ content = { filter = new_filter } })
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
      vim.keymap.set("n", "g.", toggle_hidden_files, { buffer = args.data.buf_id, desc = "Toggle Hidden Files" })
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesExplorerOpen",
    callback = function()
      show_hidden_files = false
      MiniFiles.refresh({ content = { filter = filter__hide_hidden_files } })
    end,
  })

  vim.keymap.set("n", "<leader>e", function() MiniFiles.open() end, { desc = "File Explorer" })
end)

-- mini.clue (which-key) ---------------------------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.clue" })

  local miniclue = require("mini.clue")
  miniclue.setup({
    triggers = {
      { mode = "n", keys = "<leader>" },
      { mode = "x", keys = "<leader>" },
      { mode = "n", keys = "g" },
      { mode = "x", keys = "g" },
      { mode = "n", keys = "'" },
      { mode = "n", keys = "`" },
      { mode = "n", keys = '"' },
      { mode = "x", keys = '"' },
      { mode = "i", keys = "<C-r>" },
      { mode = "c", keys = "<C-r>" },
      { mode = "n", keys = "<C-w>" },
      { mode = "n", keys = "z" },
      { mode = "x", keys = "z" },
    },

    clues = {
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),

      { mode = "n", keys = "<leader>f", desc = "+Find" },
      { mode = "n", keys = "<leader>c", desc = "+Code" },
      { mode = "n", keys = "<leader>g", desc = "+Git" },
      { mode = "n", keys = "<leader>t", desc = "+Terminal" },
      { mode = "n", keys = "<leader>b", desc = "+Buffer" },
      { mode = "n", keys = "<leader>a", desc = "+AI" },
      { mode = "n", keys = "<leader>x", desc = "+Text" },
      { mode = "n", keys = "<leader>w", desc = "+Tab" },
    },

    window = {
      config = { width = "auto" },
    },
  })
end)

-- mini.completion -----------------------------------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.completion" })
  -- Default completion delay is 100ms, which pops the suggestion menu up almost
  -- immediately after typing a snippet prefix like "env" -- stealing the following
  -- <Tab> to navigate the popup instead of triggering snippets.lua's expand. 700ms
  -- (matching ronisbr's config) gives enough room to type a prefix and hit <Tab>
  -- before the popup shows, while still auto-completing on genuinely idle typing.
  require("mini.completion").setup({
    delay = { completion = 700, info = 300, signature = 200 },
  })
end)

-- mini.diff -----------------------------------------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.diff" })
  require("mini.diff").setup()

  vim.keymap.set("n", "<leader>go", function() MiniDiff.toggle_overlay() end, { desc = "Toggle Diff Overlay" })
end)

-- mini.git ------------------------------------------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ { src = "https://github.com/nvim-mini/mini-git", name = "mini.git" } })
  require("mini.git").setup()
end)

-- mini.bufremove ------------------------------------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.bufremove" })
  require("mini.bufremove").setup()

  vim.keymap.set("n", "<leader>bd", function() MiniBufremove.delete() end, { desc = "Delete Buffer (Keep Layout)" })
end)

-- mini.move -----------------------------------------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.move" })
  require("mini.move").setup()
end)

-- mini.splitjoin ------------------------------------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.splitjoin" })
  require("mini.splitjoin").setup()
end)

-- mini.indentscope ----------------------------------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.indentscope" })
  require("mini.indentscope").setup()
end)

-- mini.trailspace -----------------------------------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.trailspace" })
  require("mini.trailspace").setup()

  vim.keymap.set("n", "<leader>cw", function() MiniTrailspace.trim() end, { desc = "Trim Trailing Whitespace" })
end)

-- mini.hipatterns -----------------------------------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.hipatterns" })
  local hipatterns = require("mini.hipatterns")
  hipatterns.setup({
    highlighters = {
      fixme     = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
      hack      = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
      todo      = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
      note      = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

-- mini.align -----------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.align" })
  require("mini.align").setup()
end)

-- mini.starter --------------------------------------------------------------------------------

-- `now`, not `later`: the dashboard must be ready to show as soon as the UI attaches, or
-- Neovim briefly shows a blank buffer first.
MiniMisc.now(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.starter" })

  local neovim_logo = [[
  │ ╲ ││
  ││╲╲││
  ││ ╲ │

  NVIM v]] .. tostring(vim.version()) .. "\n"

  local neovim_logo_separator = [[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━]]

  -- Center the header.
  local function center_header(content)
    local max_width = 0

    for _, line in ipairs(content) do
      for _, unit in ipairs(line) do
        local width = vim.fn.strdisplaywidth(unit.string)

        if width > max_width then
          max_width = width
        end
      end
    end

    local coords = {}
    vim.list_extend(coords, MiniStarter.content_coords(content, "header"))
    vim.list_extend(coords, MiniStarter.content_coords(content, "footer"))

    for _, c in ipairs(coords) do
      local line = content[c.line]

      local line_width = 0
      for _, unit in ipairs(line) do
        line_width = line_width + vim.fn.strdisplaywidth(unit.string)
      end

      local pad = math.max(math.floor((max_width - line_width) / 2), 0)
      local left_pad = #line > 0 and string.rep(" ", pad) or ""

      table.insert(line, 1, { string = left_pad, type = "empty" })
    end

    return content
  end

  -- Highlight the N logo: left vertical stroke in one color, rest in another.
  local function highlight_logo(content)
    -- │ is U+2502 = 3 bytes in UTF-8. Lua's `?` only makes one byte optional, so we need
    -- to try the two-character match first, then fall back to one.
    local bar2 = "││"
    local bar1 = "│"

    for _, line in ipairs(content) do
      for j, unit in ipairs(line) do
        if unit.type == "header" then
          local s = unit.string

          local left, rest = s:match("^(%s*" .. bar2 .. ")(.*)")

          if not left then
            left, rest = s:match("^(%s*" .. bar1 .. ")(.*)")
          end

          if left then
            unit.string = left
            unit.hl = "Changed"

            if rest ~= "" then
              table.insert(line, j + 1, { string = rest, type = "header", hl = "Added" })
            end
          else
            unit.hl = "Normal"
          end

          break
        end
      end
    end
    return content
  end

  -- Add the separator after the last header line, centered on screen independently of the
  -- header centering.
  local function separators(content)
    local sep_width = vim.fn.strdisplaywidth(neovim_logo_separator)
    local pad = math.max(math.floor((vim.o.columns - sep_width) / 2), 0)

    local last_header_line = 0
    for i, line in ipairs(content) do
      for _, unit in ipairs(line) do
        if unit.type == "header" then
          last_header_line = i
          break
        end
      end
    end

    if last_header_line > 0 then
      table.insert(content, last_header_line + 1, {
        { string = string.rep(" ", pad),  type = "empty" },
        { string = neovim_logo_separator, type = "header", hl = "Normal" },
      })
    end

    table.insert(content, #content + 1, {
      { string = string.rep(" ", pad),  type = "empty" },
      { string = neovim_logo_separator, type = "header", hl = "Normal" },
    })

    return content
  end

  -- Footer showing loaded-plugin count and startup time.
  local function mini_starter_footer()
    local num_plugins_str = ""
    if _G.__nvim_num_loaded_plugins then
      num_plugins_str = string.format("Loaded Plugins : %d", _G.__nvim_num_loaded_plugins)
    end

    local startup_time_str = ""
    if _G.__nvim_startup_time then
      startup_time_str = string.format("Startup Time   : %d ms", _G.__nvim_startup_time)
    end

    local np_width = vim.fn.strdisplaywidth(num_plugins_str)
    local st_width = vim.fn.strdisplaywidth(startup_time_str)
    local max_width = math.max(np_width, st_width)
    local np_right_pad = string.rep(" ", max_width - np_width)
    local st_right_pad = string.rep(" ", max_width - st_width)

    return "\n" ..
      num_plugins_str .. np_right_pad .. "\n" ..
      startup_time_str .. st_right_pad .. "\n"
  end

  local starter = require("mini.starter")

  local items = {
    { name = "Find File",      action = ":Pick files",                           section = "Actions" },
    { name = "New File",       action = ":ene | startinsert",                    section = "Actions" },
    { name = "Find Text",      action = ":Pick grep_live",                       section = "Actions" },
    { name = "Recent Files",   action = ":Pick oldfiles",                        section = "Actions" },
    { name = "Config",         action = ":lua MiniFiles.open('~/.config/nvim')", section = "Actions" },
    { name = "LazyGit",        action = ":LazyGit",                              section = "Actions" },
    { name = "Update Plugins", action = ":lua vim.pack.update()",                section = "Actions" },
    { name = "Quit",           action = ":qa",                                   section = "Actions" },
    starter.sections.recent_files(8, false, false),
  }

  starter.setup({
    header = neovim_logo,
    items = items,
    footer = mini_starter_footer,
    content_hooks = {
      starter.gen_hook.adding_bullet(),
      center_header,
      starter.gen_hook.aligning("center", "center"),
      highlight_logo,
      -- Add the separator after aligning so it does not affect centering. Also, notice
      -- that we need to add after changing the highlighting so that we can choose the
      -- separator color.
      separators,
    },
  })

  -- Refresh the mini.starter after startup finishes, updating the startup time shown.
  vim.api.nvim_create_autocmd("User", {
    pattern = "StartupFinished",
    once = true,
    callback = function()
      if not _G.__nvim_startup_time then
        local started = _G.__nvim_start_time
        if not started then return end
        local dt_ns = vim.uv.hrtime() - started
        _G.__nvim_startup_time = math.floor(dt_ns / 1e6 + 0.5)
      end

      if vim.bo.filetype == "ministarter" then
        MiniStarter.refresh()
      end
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniStarterOpened",
    callback = function()
      -- Disable indentscope on the starter buffer.
      vim.b.miniindentscope_disable = true

      -- Remove characters at the end of buffer.
      vim.opt_local.fillchars = "eob: "

      -- Hide the status line by changing its highlight group.
      local ns = vim.api.nvim_create_namespace("mini_starter_statusline_ns")
      vim.api.nvim_set_hl(ns, "StatusLine", { link = "Normal" })
      vim.api.nvim_set_hl(ns, "StatusLineNC", { link = "Normal" })

      vim.api.nvim_win_set_hl_ns(0, ns)
    end,
  })
end)

-- mini.extra -----------------------------------------------------------------------------

MiniMisc.later(function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.extra" })
  require("mini.extra").setup()
end)
