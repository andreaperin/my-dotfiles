-- Deferred until the first CmdlineEnter (`:`, `/`, etc.) -- sessions that never touch the
-- cmdline skip loading this entirely. Note: the pumheight-10 cap registered below only
-- takes effect from the *second* cmdline entry onward, since an autocmd registered while
-- already handling an event doesn't retroactively apply to that same in-progress one --
-- a known, accepted quirk in ronisbr's own version of this same pattern.
MiniMisc.on_event("CmdLineEnter", function()
  vim.pack.add({ "https://github.com/nvim-mini/mini.cmdline" })
  require("mini.cmdline").setup()

  -- Limit the popup menu height while the cmdline is open, so completion candidates (e.g.
  -- typing `:e ` and tab-completing a long file list) don't cover too much of the screen.
  -- 0 (unlimited) is restored on leave so it doesn't affect insert-mode completion elsewhere.
  vim.api.nvim_create_autocmd("CmdlineEnter", {
    callback = function() vim.o.pumheight = 10 end,
  })
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function() vim.o.pumheight = 0 end,
  })
end)
