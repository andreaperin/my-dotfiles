MiniMisc.on_filetype("typst", function()
  vim.pack.add({ "https://github.com/chomosuke/typst-preview.nvim" })
  require("typst-preview").setup()

  -- Buffer-local, not global: without `buffer = args.buf` this leaks into every other
  -- filetype too (including .tex, where :TypstPreviewToggle just fails trying to treat
  -- it as Typst source) once any .typ file has been opened once in the session.
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "typst",
    callback = function(args)
      vim.keymap.set("n", "<leader>ct", "<Cmd>TypstPreviewToggle<CR>", { buffer = args.buf, desc = "Toggle Typst Preview" })
    end,
  })
end)
