-- Model/provider switcher for the "99" AI plugin, via vim.ui.select (routed to
-- MiniPick.ui_select in mini.lua) instead of 99's own telescope.nvim/fzf-lua
-- extensions -- neither of which this config uses. Mirrors
-- `99.extensions.telescope`/`99.extensions.fzf_lua` exactly, built on the same shared
-- `99.extensions.pickers` data/apply logic they use, just with a different picker UI.

local M = {}

--- @param provider _99.Providers.BaseProvider?
function M.select_model(provider)
  local pickers_util = require("99.extensions.pickers")

  pickers_util.get_models(provider, function(models, current)
    vim.ui.select(models, {
      prompt = "99: Select Model (current: " .. current .. ")",
    }, function(choice)
      if choice then
        pickers_util.on_model_selected(choice)
      end
    end)
  end)
end

function M.select_provider()
  local pickers_util = require("99.extensions.pickers")
  local info = pickers_util.get_providers()

  vim.ui.select(info.names, {
    prompt = "99: Select Provider (current: " .. info.current .. ")",
  }, function(choice)
    if choice then
      pickers_util.on_provider_selected(choice, info.lookup)
    end
  end)
end

return M
