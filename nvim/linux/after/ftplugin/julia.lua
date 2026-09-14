vim.bo.commentstring = "# %s"

local function _julia_format_bullet(lines, tw)
  if not lines[1]:match("^%s*[-*+]%s") then return nil end

  local parts = {}
  for i, line in ipairs(lines) do
    local text = i == 1 and line or (line:match("^%s*(.-)%s*$") or "")
    if text ~= "" then table.insert(parts, text) end
  end

  local all_text = table.concat(parts, " "):gsub("%s+", " ")
  local cont     = string.rep(" ", vim.fn.shiftwidth())
  local result   = {}
  local current  = ""

  for word in all_text:gmatch("%S+") do
    if current == "" then
      current = word
    elseif #current + 1 + #word <= tw then
      current = current .. " " .. word
    else
      table.insert(result, current)
      current = cont .. word
    end
  end

  if current ~= "" then table.insert(result, current) end
  return result
end

local function julia_formatexpr()
  local start_lnum = vim.v.lnum
  local count      = vim.v.count
  local tw         = vim.bo.textwidth > 0 and vim.bo.textwidth or 79
  local lines      = vim.api.nvim_buf_get_lines(0, start_lnum - 1, start_lnum + count - 1, false)
  local result     = _julia_format_bullet(lines, tw)

  if result then
    vim.api.nvim_buf_set_lines(0, start_lnum - 1, start_lnum + count - 1, false, result)
    return 0
  end

  local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/rangeFormatting" })
  if #clients > 0 then
    local end_lnum = start_lnum + count - 1
    vim.lsp.buf.format({
      range = {
        start  = { start_lnum, 0 },
        ["end"] = { end_lnum, #vim.fn.getline(end_lnum) },
      },
    })
    return 0
  end

  return 1
end

_G.cincinperin_julia_formatexpr = julia_formatexpr
vim.bo.formatexpr = "v:lua.cincinperin_julia_formatexpr()"

-- Runic formatting ---------------------------------------------------------------------

local function runic_format()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
  local input = table.concat(lines, "\n") .. "\n"

  local result = vim.system({ "runic" }, { stdin = input, text = true }):wait()

  if result.code ~= 0 then
    vim.notify("Runic formatting failed:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
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

vim.keymap.set("n", "<leader>cf", runic_format, { buffer = true, desc = "Format Buffer (Runic)" })

vim.api.nvim_create_autocmd("BufWritePre", {
  buffer = 0,
  callback = runic_format,
})
