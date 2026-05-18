-- install lazy.nvim automatically
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"   --yank to clipboard

-- tabs & indentation
vim.opt.tabstop = 2        -- visible width of tabs
vim.opt.shiftwidth = 2     -- spaces used for autoindent
vim.opt.softtabstop = 2    -- spaces when pressing Tab
vim.opt.expandtab = true   -- convert tabs to spaces
vim.opt.smartindent = true -- smart auto indentation
vim.opt.autoindent = true  -- keep indentation from previous line
vim.opt.wrap = false       -- disable line wrapping
vim.opt.scrolloff = 8      -- keep cursor away from screen edges
vim.opt.number = true
vim.opt.relativenumber = true


require("lazy").setup({
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("kanagawa-wave")
    end,
  },
})
