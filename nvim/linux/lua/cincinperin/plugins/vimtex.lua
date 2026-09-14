-- `on_filetype`, not a plain `once`-autocmd: besides only firing once, it re-triggers
-- FileType processing for the buffer that caused the load (`vim.bo.filetype =
-- vim.bo.filetype` under the hood) -- which is exactly what's needed here, since
-- vim.pack.add loads vimtex's own FileType-tex autocmd too late to catch the event for
-- the buffer that triggered this callback otherwise.
MiniMisc.on_filetype("tex", function()
  vim.g.vimtex_view_general_viewer = "okular"
  vim.g.vimtex_view_general_options = [[--unique file:@pdf\#src:@line@tex]]
  vim.g.vimtex_compiler_latexmk = { continuous = 0 }

  vim.pack.add({ "https://github.com/lervag/vimtex" })
end)
