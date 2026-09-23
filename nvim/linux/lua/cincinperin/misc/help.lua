-- Personal quick-reference popup (<leader>h): every custom command introduced in this
-- config, grouped by area. Not a replacement for CHEATSHEET.md (which has full prose,
-- rationale, and gotchas) -- this is the fast, scannable version for "what was that key
-- again?" while actually editing.

local float = require("cincinperin.misc.float")

local M = {}

local groups = {
  {
    title = "Buffers",
    entries = {
      { "[b / ]b", "Previous / next buffer" },
      { "<leader>bd", "Delete current buffer, keep window layout" },
      { "<leader>bw", "Close all buffers except the current one" },
      { "<leader>bf", "(Julia) include() current file in right terminal" },
      { "<leader>bv", "(Julia) show REPL variables (varinfo()) in a float" },
    },
  },
  {
    title = "Tabs",
    entries = {
      { "[t / ]t", "Previous / next tab" },
      { "<leader>wn", "New tab" },
      { "<leader>wc", "Close current tab" },
      { "<leader>wo", "Close all tabs except the current one" },
    },
  },
  {
    title = "Windows & Splits (vanilla)",
    entries = {
      { "Ctrl-w v", "Vertical split" },
      { "Ctrl-w s", "Horizontal split" },
      { "Ctrl-w h/j/k/l", "Move focus between splits" },
    },
  },
  {
    title = "Terminal",
    entries = {
      { "<F5> / <leader>tf", "Toggle floating terminal" },
      { "<F6> / <leader>tr", "Toggle right-side terminal" },
      { "<leader>tb", "Toggle bottom terminal (independent from the right one)" },
      { "<Esc> <Esc> (fast)", "Exit terminal-mode -- single <Esc> goes to the program inside" },
      { "Ctrl-w h/j/k/l", "Move focus out of right/bottom terminal, still in terminal-mode" },
    },
  },
  {
    title = "Send to Terminal",
    entries = {
      { "<leader>ts", "Send buffer (normal) / selection (visual) to the right terminal" },
      { "<leader>ti", "Same as <leader>ts, then focus the right terminal" },
      { "<leader>bf", "(Julia) include(\"<file>\") in the right terminal, not raw text" },
    },
  },
  {
    title = "Formatting",
    entries = {
      { "gq{motion} / gqq", "(vanilla) Reflow text to textwidth -- bullet-aware in Julia" },
      { "gg=G", "(vanilla) Re-indent whole buffer via tree-sitter" },
      { "gcc / gc{motion}", "(vanilla, native) Toggle comment -- right syntax per filetype" },
      { "<leader>cf", "Format buffer: Runic (Julia) / latexindent (LaTeX)" },
      { "(automatic)", "Runic / latexindent also run on every :w of that filetype" },
      { "<leader>cw", "Trim trailing whitespace" },
      { "gS", "Toggle a bracketed construct one-line <-> multi-line" },
      { "ga{char}", "(visual) Align selection on a character, e.g. ga=" },
    },
  },
  {
    title = "Julia",
    entries = {
      { "\\alpha, \\in, \\_1, ...", "Auto-converts to Unicode on next non-identifier char" },
      { "<leader>cf", "Format buffer with Runic" },
      { "<leader>bf", "include() current file in the right terminal's REPL" },
      { "<leader>bv", "Show REPL variables in a floating window" },
      { "IRZ<Tab>, desc<Tab>", "Snippets: file header / description banner" },
    },
  },
  {
    title = "LaTeX (localleader = \\)",
    entries = {
      { "\\ll", "Compile (latexmk)" },
      { "\\lv", "Forward search -- jump to cursor location in Okular" },
      { "\\lt", "Toggle table of contents" },
      { "\\lc", "Clean build files" },
      { "\\le", "Show compile errors (quickfix)" },
      { "<leader>cf", "Format buffer with latexindent" },
      { "env/fig/tab/bf/it/tt/mbf<Tab>", "Snippets" },
    },
  },
  {
    title = "Typst",
    entries = {
      { "<leader>ct", "Toggle live preview (bidirectional cursor sync)" },
      { "<leader>cc", "Compile to a standalone PDF (auto-saves first)" },
    },
  },
  {
    title = "Markdown",
    entries = {
      { "<leader>cm", "Toggle live browser preview" },
    },
  },
  {
    title = "AI Assistant (99)",
    entries = {
      { "<leader>9v", "(visual) Edit selection with a prompt" },
      { "<leader>9s", "Search project with a prompt (results -> quickfix)" },
      { "<leader>9x", "Stop all in-flight requests" },
      { "<leader>9o", "Open last interaction's results" },
      { "<leader>9l", "View request/response logs" },
      { "<leader>9m", "Switch model for current provider" },
      { "<leader>9p", "Switch provider (Claude/OpenCode/Gemini/...)" },
    },
  },
  {
    title = "Git",
    entries = {
      { "<leader>gg", "Open LazyGit (floating)" },
      { "<leader>gl", "Open LazyGit at the commit log" },
      { "<leader>go", "Toggle inline diff overlay vs HEAD" },
      { ":Git <args>", "Thin fugitive-like wrapper, e.g. :Git blame" },
    },
  },
  {
    title = "Search",
    entries = {
      { "/pattern, n / N", "Search, jump next/previous (match-count shown via hlslens)" },
      { "* / #", "Search word under cursor, whole-word" },
      { "g* / g#", "Search word under cursor, substring match" },
      { "<Esc>", "Clear search highlight" },
    },
  },
  {
    title = "Multicursor",
    entries = {
      { "<leader>m", "Select word/selection, enter multicursor mode" },
      { "Ctrl-a (in mode)", "Select every other occurrence" },
      { "n / N (in mode)", "Step to next/previous occurrence" },
      { "i/a/c/d (in mode)", "Insert/append/change/delete on every cursor" },
      { "<Esc> (in mode)", "Clear selections" },
    },
  },
  {
    title = "Finding Things",
    entries = {
      { "<leader>ff", "Find files" },
      { "<leader>fg", "Live grep" },
      { "<leader>fb", "Find open buffers" },
      { "<leader>fh", "Search help tags" },
      { "<leader>e", "File explorer (mini.files)" },
    },
  },
  {
    title = "Undo History",
    entries = {
      { "<leader>u", "Toggle Undotree (visual undo history)" },
    },
  },
  {
    title = "Spellcheck",
    entries = {
      { ":set spell / nospell", "Turn spell-check on / off (buffer-local)" },
      { "]s / [s", "Next / previous flagged word" },
      { "z=", "Suggestions for the word under the cursor" },
      { "zg / zw", "Mark word as good / wrong" },
      { "zug / zuw", "Undo a zg / zw" },
      { ":echo spellbadword()", "Why a word is flagged: bad/rare/local/caps" },
    },
  },
  {
    title = "Misc",
    entries = {
      { "<leader>z", "Toggle soft wrap (wrap + linebreak)" },
      { "<leader>ac", "Copy file:line reference to clipboard" },
      { "<leader>xb", "Convert 2 lines into a centered box" },
      { "<leader>pv", "Open netrw at current file's directory" },
      { "q", "Close help/quickfix/notify/etc. windows" },
    },
  },
}

local function build_lines()
  local lines = {}
  local title_lines = {}

  for _, group in ipairs(groups) do
    if #lines > 0 then
      table.insert(lines, "")
    end

    table.insert(lines, group.title)
    title_lines[#lines] = true

    local key_width = 0
    for _, entry in ipairs(group.entries) do
      key_width = math.max(key_width, #entry[1])
    end

    for _, entry in ipairs(group.entries) do
      local key, desc = entry[1], entry[2]
      table.insert(lines, "  " .. key .. string.rep(" ", key_width - #key) .. "   " .. desc)
    end
  end

  return lines, title_lines
end

local help_float = { buf = nil, win = nil, backdrop_buf = nil, backdrop_win = nil }

local function close()
  float.close(help_float)
end

function M.show()
  local lines, title_lines = build_lines()

  if not (help_float.buf and vim.api.nvim_buf_is_valid(help_float.buf)) then
    help_float.buf = vim.api.nvim_create_buf(false, true)
  end

  vim.bo[help_float.buf].modifiable = true
  vim.api.nvim_buf_set_lines(help_float.buf, 0, -1, false, lines)
  vim.bo[help_float.buf].modifiable = false
  vim.bo[help_float.buf].filetype = "cincinperinhelp"

  local ns = vim.api.nvim_create_namespace("cincinperin_help")
  vim.api.nvim_buf_clear_namespace(help_float.buf, ns, 0, -1)
  for lnum in pairs(title_lines) do
    vim.api.nvim_buf_set_extmark(help_float.buf, ns, lnum - 1, 0, { hl_group = "Title", end_line = lnum })
  end

  local width, height, row, col = float.centered(0.7, 0.85)

  local f = float.open({
    buf = help_float.buf,
    width = width,
    height = height,
    row = row,
    col = col,
    backdrop_buf = help_float.backdrop_buf,
    title = " Cheatsheet (q to close) ",
    border = "rounded",
  })

  help_float.win, help_float.backdrop_win, help_float.backdrop_buf = f.win, f.backdrop_win, f.backdrop_buf

  for _, lhs in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", lhs, close, { buffer = help_float.buf, silent = true })
  end
end

return M
