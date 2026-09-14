-- Deferred until the first InsertEnter: Tab can only ever be pressed while already in
-- Insert mode, and InsertEnter always fires before that, so the setup below (including
-- the <Tab>/<S-Tab> mappings) is guaranteed ready by the time it could possibly matter --
-- while every session that never enters Insert mode skips loading this entirely.
MiniMisc.on_event("InsertEnter", function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.snippets" })

  local gen_loader = require("mini.snippets").gen_loader

  -- `from_lang()` derives the language from the tree-sitter parser at the cursor, which
  -- maps filetype "tex"/"plaintex" to language "latex" -- but only when a parser is
  -- actually attached. Without a fallback it silently finds nothing whenever that isn't
  -- the case, so point both filetypes at latex.json explicitly.
  local latex_patterns = { "latex/**/*.json", "latex/**/*.lua", "**/latex.json", "**/latex.lua" }

  require("mini.snippets").setup({
    -- Disable the built-in <Tab>/<S-Tab> mappings; we drive expand/jump ourselves below
    -- so <Tab> can also fall through to completion-menu navigation.
    mappings = { expand = "", jump_next = "", jump_prev = "" },
    snippets = {
      gen_loader.from_lang({
        lang_patterns = { tex = latex_patterns, plaintex = latex_patterns },
      }),
    },
  })

  -- <Tab>: jump forward in an active snippet session, else navigate the completion menu
  -- if it's open, else expand a uniquely-matching snippet, else insert a literal tab.
  --
  -- Snippet jump is checked first, ahead of pumvisible(): mini.completion's popup
  -- auto-triggers while typing plain text inside a placeholder (e.g. filling in `align`
  -- for the `env` snippet's `$1`), and if pumvisible() were checked first, Tab would
  -- silently navigate that incidental popup instead of jumping the tabstop -- confirmed
  -- empirically via a real keystroke-by-keystroke RPC session, where `cur_tabstop` stayed
  -- unchanged after Tab because pumvisible() was 1 at the time.
  vim.keymap.set("i", "<Tab>", function()
    if MiniSnippets.session.get() ~= nil then
      return MiniSnippets.session.jump("next")
    end

    if vim.fn.pumvisible() == 1 then
      return vim.api.nvim_replace_termcodes("<C-n>", true, true, true)
    end

    if #MiniSnippets.expand({ insert = false }) == 1 then
      return vim.api.nvim_replace_termcodes("<Cmd>lua MiniSnippets.expand()<CR>", true, true, true)
    end

    return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
  end, { expr = true, replace_keycodes = false, silent = true, desc = "Completion / Snippet Expand / Tab" })

  -- <S-Tab>: jump backward in an active snippet session, else navigate the completion
  -- menu backward if open, else insert a literal shift-tab. Same priority reasoning as
  -- <Tab> above.
  vim.keymap.set("i", "<S-Tab>", function()
    if MiniSnippets.session.get() ~= nil then
      return MiniSnippets.session.jump("prev")
    end

    if vim.fn.pumvisible() == 1 then
      return vim.api.nvim_replace_termcodes("<C-p>", true, true, true)
    end

    return vim.api.nvim_replace_termcodes("<S-Tab>", true, true, true)
  end, { expr = true, replace_keycodes = false, silent = true, desc = "Completion / Snippet Jump Back" })
end)
