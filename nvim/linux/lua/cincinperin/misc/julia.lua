-- Capture `varinfo()`'s output from a running Julia REPL (in the right terminal) and show
-- it in a floating window -- a lightweight "variables workspace" view, not a debugger.
--
-- Mechanism: send the command wrapped in unique sentinel markers, poll the terminal
-- buffer for the markers to appear (as their own exact lines -- the echoed *input* line
-- is much longer and contains the whole `println(...); display(...); println(...)`
-- source text, so an exact-line match reliably picks out the actual *output* instead),
-- then extract just the lines between them.

local term = require("cincinperin.misc.terminal")
local float = require("cincinperin.misc.float")

local M = {}

local var_float = { buf = nil, win = nil, backdrop_buf = nil, backdrop_win = nil }

local function close_var_float()
  float.close(var_float)
end

local function open_float(lines)
  if #lines == 0 then
    lines = { "(no output)" }
  end

  if not (var_float.buf and vim.api.nvim_buf_is_valid(var_float.buf)) then
    var_float.buf = vim.api.nvim_create_buf(false, true)
  end

  vim.bo[var_float.buf].modifiable = true
  vim.api.nvim_buf_set_lines(var_float.buf, 0, -1, false, lines)
  vim.bo[var_float.buf].modifiable = false
  vim.bo[var_float.buf].filetype = "text"

  local width, height, row, col = float.centered(0.6, 0.6)

  local f = float.open({
    buf = var_float.buf,
    width = width,
    height = height,
    row = row,
    col = col,
    backdrop_buf = var_float.backdrop_buf,
    title = " Julia Variables ",
    border = "rounded",
  })

  var_float.win, var_float.backdrop_win, var_float.backdrop_buf = f.win, f.backdrop_win, f.backdrop_buf

  for _, lhs in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", lhs, close_var_float, { buffer = var_float.buf, silent = true })
  end
end

--- Send `varinfo()` to the right terminal and show its output in a floating window.
--- Requires a Julia REPL already running there (<leader>tr, then type `julia` yourself).
function M.show_variables()
  local rt = term.right_term

  if not (rt.jobid and vim.fn.jobwait({ rt.jobid }, 0)[1] == -1) then
    vim.notify("Right terminal is not running.", vim.log.levels.ERROR)
    return
  end

  local token = tostring(vim.uv.hrtime())
  local start_marker = "###JULIA_VARS_START_" .. token .. "###"
  local end_marker = "###JULIA_VARS_END_" .. token .. "###"

  local cmd = string.format(
    'println("%s"); display(varinfo()); println("%s")\n',
    start_marker,
    end_marker
  )

  term.send_to_right_term(cmd)

  local attempts = 0
  local timer = vim.uv.new_timer()
  timer:start(200, 200, vim.schedule_wrap(function()
    attempts = attempts + 1

    if not (rt.buf and vim.api.nvim_buf_is_valid(rt.buf)) then
      timer:stop()
      timer:close()
      return
    end

    local lines = vim.api.nvim_buf_get_lines(rt.buf, 0, -1, false)

    local start_idx, end_idx
    for i, line in ipairs(lines) do
      if line == start_marker then
        start_idx = i
        end_idx = nil
      elseif start_idx and line == end_marker then
        end_idx = i
        break
      end
    end

    if start_idx and end_idx then
      timer:stop()
      timer:close()

      local output = {}
      for i = start_idx + 1, end_idx - 1 do
        table.insert(output, lines[i])
      end

      open_float(output)
    elseif attempts >= 25 then -- ~5s
      timer:stop()
      timer:close()
      vim.notify("Timed out waiting for the Julia REPL to respond -- is it actually running in the right terminal?", vim.log.levels.WARN)
    end
  end))
end

return M
