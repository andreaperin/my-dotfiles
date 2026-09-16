MiniMisc.later(function()
  vim.pack.add({ "https://github.com/ThePrimeagen/99" })

  local _99 = require("99")

  _99.setup({
    -- Starting default -- switch anytime with <leader>9p, doesn't require a restart.
    provider = _99.Providers.ClaudeCodeProvider,
  })

  vim.keymap.set("v", "<leader>9v", function() _99.visual() end, { desc = "99: Edit Visual Selection" })
  vim.keymap.set("n", "<leader>9s", function() _99.search() end, { desc = "99: Search (results in quickfix)" })
  vim.keymap.set("n", "<leader>9x", function() _99.stop_all_requests() end, { desc = "99: Stop All Requests" })
  vim.keymap.set("n", "<leader>9o", function() _99.open() end, { desc = "99: Open Last Interaction" })
  vim.keymap.set("n", "<leader>9l", function() _99.view_logs() end, { desc = "99: View Logs" })

  -- 99 only ships telescope.nvim/fzf-lua pickers for model/provider switching; this
  -- config uses mini.pick instead, so these call the same underlying
  -- `99.extensions.pickers` data/apply logic those ship with, through vim.ui.select
  -- (already routed to MiniPick.ui_select in mini.lua) rather than adding a second
  -- fuzzy-finder dependency.
  vim.keymap.set("n", "<leader>9m", function()
    require("cincinperin.misc.ninetynine_pickers").select_model()
  end, { desc = "99: Select Model" })
  vim.keymap.set("n", "<leader>9p", function()
    require("cincinperin.misc.ninetynine_pickers").select_provider()
  end, { desc = "99: Select Provider" })
end)
