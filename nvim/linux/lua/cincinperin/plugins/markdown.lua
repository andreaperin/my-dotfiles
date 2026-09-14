MiniMisc.on_filetype("markdown", function()
  vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })

  vim.pack.add({ "https://github.com/iamcco/markdown-preview.nvim" })
  -- One-time setup: downloads a pre-built preview server binary (Node.js already present,
  -- but this avoids an `npm install` build step). Idempotent -- checks the installed
  -- binary's version first and returns immediately if it's already current, so this is
  -- effectively free on every session after the first. Sync (not the async variant) so it
  -- doesn't pop open a terminal window on first-ever markdown file open.
  vim.fn["mkdp#util#install"](true)

  -- Buffer-local, not global -- see the same mistake caught and fixed for Typst's
  -- <leader>ct in typst.lua.
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(args)
      vim.keymap.set("n", "<leader>cm", "<Cmd>MarkdownPreviewToggle<CR>", { buffer = args.buf, desc = "Toggle Markdown Preview" })
    end,
  })
end)
