MiniMisc.later(function()
  vim.pack.add({
    "https://github.com/nvimtools/hydra.nvim",
    "https://github.com/smoka7/multicursors.nvim",
  })

  require("multicursors").setup({})

  vim.keymap.set({ "n", "v" }, "<leader>m", "<Cmd>MCstart<CR>", { desc = "Multicursor Start" })
end)
