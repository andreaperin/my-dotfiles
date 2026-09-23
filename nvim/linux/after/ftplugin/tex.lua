-- Don't hide LaTeX syntax behind concealed symbols (e.g. \alpha -> α, math delimiters).
vim.opt_local.conceallevel = 0

-- One sentence per line: soft wrap always on, and no hard wrapping ever. `t` is on by
-- default for tex and would break sentences at `textwidth` while typing.
vim.opt_local.breakindent = true
vim.opt_local.colorcolumn = ""
vim.opt_local.linebreak = true
vim.opt_local.showbreak = "↳ "
vim.opt_local.textwidth = 0
vim.opt_local.wrap = true
vim.opt_local.formatoptions:remove("t")

-- Parse syntax from the top of the file, not from 50 lines above the window: a lone `$`
-- (e.g. listings' `alsoother={$}`) reads as an unclosed math zone, so colours would
-- otherwise depend on where you scrolled from. Scheduled, since vimtex's own syntax file
-- loads after this ftplugin and would reset the sync setting.
vim.schedule(function()
  if vim.bo.filetype == "tex" then
    vim.cmd("syntax sync fromstart")
  end
end)

-- Latexindent formatting ----------------------------------------------------------------

local function latexindent_format()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
  local input = table.concat(lines, "\n") .. "\n"

  local result = vim.system({ "latexindent", "-" }, { stdin = input, text = true }):wait()

  if result.code ~= 0 then
    vim.notify("latexindent formatting failed:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
    return
  end

  local formatted = vim.split(result.stdout, "\n")
  if formatted[#formatted] == "" then
    table.remove(formatted)
  end

  if vim.deep_equal(lines, formatted) then
    return
  end

  local view = vim.fn.winsaveview()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, formatted)
  vim.fn.winrestview(view)
end

vim.keymap.set("n", "<leader>cf", latexindent_format, { buffer = true, desc = "Format Buffer (latexindent)" })

vim.api.nvim_create_autocmd("BufWritePre", {
  buffer = 0,
  callback = latexindent_format,
})
