-- MiniMisc's `safely(when, f)` is the real scheduler underneath: 'now' runs immediately,
-- 'later' queues to run right after startup without blocking it, 'event:X'/'filetype:X'
-- defer until that event/filetype first occurs. now/later/on_event/on_filetype below are
-- just friendlier names for it (matching ronisbr's own wrapper names) -- must be set up
-- before any other plugin file below, since they all use it to control load timing.
vim.pack.add({ "https://github.com/nvim-mini/mini.misc" })

_G.MiniMisc = require("mini.misc")
MiniMisc.setup()

_G.MiniMisc.later = function(f) MiniMisc.safely("later", f) end
_G.MiniMisc.now = function(f) MiniMisc.safely("now", f) end
_G.MiniMisc.on_event = function(ev, f) MiniMisc.safely("event:" .. ev, f) end
_G.MiniMisc.on_filetype = function(ft, f) MiniMisc.safely("filetype:" .. ft, f) end

vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },
  "https://github.com/eandrju/cellular-automaton.nvim",
})

require("cincinperin.plugins.colors")
require("cincinperin.plugins.undotree")
require("cincinperin.plugins.mini")
require("cincinperin.plugins.treesitter")
require("cincinperin.plugins.lsp")
require("cincinperin.plugins.julia")
require("cincinperin.plugins.vimtex")
require("cincinperin.plugins.typst")
require("cincinperin.plugins.markdown")
require("cincinperin.plugins.hlslens")
require("cincinperin.plugins.multicursors")
require("cincinperin.plugins.terminal")
require("cincinperin.plugins.lazygit")
require("cincinperin.plugins.snippets")
require("cincinperin.plugins.cmdline")
require("cincinperin.plugins.99")

require("cincinperin.misc.statusline").setup()

MiniMisc.now(function()
  _G.__nvim_num_loaded_plugins = #vim.pack.get(nil, { info = false })
  vim.cmd("doautocmd User StartupFinished")
end)
