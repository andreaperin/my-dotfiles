-- Cursor-count helper for the statusline's multicursor badge.
--
-- ronisbr's statusline reads a `misc.multicursor` module tracking Neovim's *native*
-- nightly multicursor (`:h multicursor`), which also has a "follow mode" concept. We use
-- the `multicursors.nvim` plugin instead (stable Neovim has no native multicursor), which
-- has neither a public API nor a follow-mode concept -- so this counts active selections
-- via the plugin's internal `multicursors.utils` module instead, and the badge never shows
-- a follow-mode variant.

local M = {}

function M.cursors()
  local ok, utils = pcall(require, "multicursors.utils")
  if not ok then
    return 0
  end

  local main = utils.get_main_selection()
  local extra = utils.get_all_selections()

  local count = #extra
  if main.row ~= nil then
    count = count + 1
  end

  return count
end

return M
