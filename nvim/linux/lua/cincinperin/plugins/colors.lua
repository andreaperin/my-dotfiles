function ColorMyPencils(color)
  color = color or "kanagawa"
  vim.cmd.colorscheme(color)

  -- `nvim_set_hl` replaces the whole highlight definition rather than merging into it, so
  -- setting bg=none below would otherwise silently wipe out fg too. Capture the
  -- colorscheme's real fg first and re-apply it, so Normal/NormalFloat stay queryable by
  -- anything that reads their fg (e.g. misc/lazygit.lua's theme generator).
  local normal_fg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg
  local normalfloat_fg = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false }).fg

  vim.api.nvim_set_hl(0, "Normal", { bg = "none", fg = normal_fg })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none", fg = normalfloat_fg })
end

-- `now`, not `later`: the colorscheme must be applied before the first paint, or the
-- editor flashes default colors first.
MiniMisc.now(function()
  vim.pack.add({
    "https://github.com/rebelot/kanagawa.nvim",
    "https://github.com/erikbackman/brightburn.vim",
    { src = "https://github.com/ellisonleao/gruvbox.nvim", name = "gruvbox" },
    "https://github.com/folke/tokyonight.nvim",
    { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
  })

  require("kanagawa").setup({ transparent = true, theme = "wave" })
  require("gruvbox").setup({ transparent_mode = true })
  require("tokyonight").setup({ style = "storm", transparent = true })
  require("rose-pine").setup({ disable_background = true })

  ColorMyPencils()
end)
