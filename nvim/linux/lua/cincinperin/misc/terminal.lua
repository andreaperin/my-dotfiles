local float = require("cincinperin.misc.float")

local M = {}

local esc_key = vim.keycode("<Esc>")
local terminal_shell = "zsh"

M.floating_term = {
  buf = nil, win = nil, jobid = nil,
  backdrop_buf = nil, backdrop_win = nil,
}
M.right_term = { buf = nil, win = nil, jobid = nil }
M.bottom_term = { buf = nil, win = nil, jobid = nil }

-- Pressing <Esc> once sends it to the terminal after 200ms (useful for TUI apps running
-- inside); pressing it twice quickly exits to normal mode instead.
local function map_double_esc(buf, get_jobid)
  local timer = vim.uv.new_timer()

  vim.keymap.set(
    "t",
    "<Esc>",
    function()
      if timer:is_active() then
        timer:stop()
        vim.cmd.stopinsert()
        vim.schedule(function() vim.fn.getchar(0) end)
      else
        timer:start(200, 0, vim.schedule_wrap(function()
          local jobid = get_jobid()
          if jobid then
            vim.fn.chansend(jobid, esc_key)
          end
        end))
      end
      return ""
    end,
    { buffer = buf, expr = true, silent = true }
  )
end

local function toggle_floating_terminal()
  local ft = M.floating_term

  if ft.win and vim.api.nvim_win_is_valid(ft.win) then
    float.close(ft)
    return
  end

  local is_new = not (ft.buf and vim.api.nvim_buf_is_valid(ft.buf))
  if is_new then
    ft.buf = vim.api.nvim_create_buf(false, true)
  end

  local width, height, row, col = float.centered(0.8, 0.8)

  local f = float.open({
    buf = ft.buf,
    width = width,
    height = height,
    row = row,
    col = col,
    backdrop_buf = ft.backdrop_buf,
  })

  ft.win, ft.backdrop_win, ft.backdrop_buf = f.win, f.backdrop_win, f.backdrop_buf

  if is_new then
    ft.jobid = vim.fn.jobstart(terminal_shell, {
      term = true,
      on_exit = function() ft.jobid = nil end,
    })
    vim.bo[ft.buf].filetype = "terminal"
    map_double_esc(ft.buf, function() return ft.jobid end)

    vim.api.nvim_create_autocmd("BufWipeout", {
      buffer = ft.buf,
      callback = function() float.close(ft) end,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
      callback = function(args)
        if tonumber(args.match) == ft.win then
          ft.win = nil
          float.close(ft)
        end
      end,
    })
  end

  vim.cmd.startinsert()
end

-- Build a toggle function for a split-window terminal (as opposed to the floating one
-- above): opens `split_cmd` the first time, reuses the same buffer/job on repeat toggles,
-- hides (not wipes) the window when toggled while open. `state` is one of the `M.*_term`
-- tables above, keeping each terminal's buf/win/jobid independent.
local function make_split_terminal_toggle(state, split_cmd)
  return function()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
      vim.api.nvim_win_hide(state.win)
      return
    end

    local is_new = not (state.buf and vim.api.nvim_buf_is_valid(state.buf))
    if is_new then
      state.buf = vim.api.nvim_create_buf(false, true)
    end

    vim.cmd(split_cmd)
    state.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(state.win, state.buf)
    vim.wo[state.win].cursorline = false

    if is_new then
      state.jobid = vim.fn.jobstart(terminal_shell, {
        term = true,
        on_exit = function() state.jobid = nil end,
      })
      vim.bo[state.buf].filetype = "terminal"

      for _, dir in ipairs({ "h", "j", "k", "l" }) do
        vim.keymap.set("t", "<C-w>" .. dir, "<C-\\><C-n><C-w>" .. dir, { buffer = state.buf, silent = true })
      end

      map_double_esc(state.buf, function() return state.jobid end)

      vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = state.buf,
        callback = function()
          if state.win and vim.api.nvim_win_is_valid(state.win) then
            vim.api.nvim_win_close(state.win, true)
          end
          state.win = nil
        end,
      })

      vim.api.nvim_create_autocmd("BufEnter", {
        buffer = state.buf,
        callback = function()
          vim.wo.cursorline = false
          vim.cmd.startinsert()
        end,
      })
    end

    vim.cmd.startinsert()
  end
end

local toggle_right_terminal = make_split_terminal_toggle(M.right_term, "botright 80vsplit")
local toggle_bottom_terminal = make_split_terminal_toggle(M.bottom_term, "botright 15split")

local function buffer_text()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return table.concat(lines, "\n"):gsub("[\r\n]+$", "") .. "\n"
end

local function visual_text()
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
  return table.concat(lines, "\n"):gsub("[\r\n]+$", "") .. "\n"
end

local function focus_right_term()
  if M.right_term.win and vim.api.nvim_win_is_valid(M.right_term.win) then
    vim.api.nvim_set_current_win(M.right_term.win)
  end
end

--- Send `text` to the right terminal.
--- @param text string
function M.send_to_right_term(text)
  local rt = M.right_term

  if not (rt.jobid and vim.fn.jobwait({ rt.jobid }, 0)[1] == -1) then
    vim.notify("Right terminal is not running.", vim.log.levels.ERROR)
    return
  end

  vim.fn.chansend(rt.jobid, text)

  if rt.win and vim.api.nvim_win_is_valid(rt.win) then
    vim.api.nvim_win_set_cursor(rt.win, { vim.api.nvim_buf_line_count(rt.buf), 0 })
  end
end

function M.setup()
  vim.keymap.set({ "n", "t" }, "<F5>", toggle_floating_terminal, { desc = "Toggle Floating Terminal" })
  vim.keymap.set("i", "<F5>", "<Esc><Cmd>lua require('cincinperin.misc.terminal')._toggle_floating()<CR>", { desc = "Toggle Floating Terminal" })
  vim.keymap.set({ "n", "t" }, "<F6>", toggle_right_terminal, { desc = "Toggle Right Terminal" })
  vim.keymap.set("i", "<F6>", "<Esc><Cmd>lua require('cincinperin.misc.terminal')._toggle_right()<CR>", { desc = "Toggle Right Terminal" })

  vim.keymap.set("n", "<leader>tf", toggle_floating_terminal, { desc = "Toggle Floating Terminal" })
  vim.keymap.set("n", "<leader>tr", toggle_right_terminal, { desc = "Toggle Right Terminal" })
  vim.keymap.set("n", "<leader>tb", toggle_bottom_terminal, { desc = "Toggle Bottom Terminal" })

  vim.keymap.set("n", "<leader>ts", function() M.send_to_right_term(buffer_text()) end, { desc = "Send Buffer to Right Terminal" })
  vim.keymap.set("v", "<leader>ts", function() M.send_to_right_term(visual_text()) end, { desc = "Send Selection to Right Terminal" })
  vim.keymap.set("n", "<leader>ti", function()
    M.send_to_right_term(buffer_text())
    focus_right_term()
  end, { desc = "Send Buffer to Right Terminal with Focus" })
  vim.keymap.set("v", "<leader>ti", function()
    M.send_to_right_term(visual_text())
    focus_right_term()
    vim.api.nvim_feedkeys(esc_key, "n", false)
  end, { desc = "Send Selection to Right Terminal with Focus" })
end

M._toggle_floating = toggle_floating_terminal
M._toggle_right = toggle_right_terminal
M._toggle_bottom = toggle_bottom_terminal

return M
