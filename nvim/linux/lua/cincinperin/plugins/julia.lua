MiniMisc.now(function()
  vim.pack.add({ "https://github.com/JuliaEditorSupport/julia-vim" })

  vim.g.latex_to_unicode_tab = false
  vim.g.latex_to_unicode_auto = true

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "julia",
    callback = function(args)
      vim.cmd("setlocal completefunc=LaTeXtoUnicode#completefunc")

      -- `include()` re-reads the file from disk (unlike sending buffer text, which is
      -- already possible generically via <leader>ts), so error stacktraces keep correct
      -- line numbers and relative include()/@__DIR__ calls inside the file work correctly.
      -- Assumes a Julia REPL is already running in the right terminal (<leader>tr, then
      -- type `julia` yourself) -- this only sends the include() command, nothing more.
      vim.keymap.set("n", "<leader>bf", function()
        local filepath = vim.api.nvim_buf_get_name(args.buf)
        require("cincinperin.misc.terminal").send_to_right_term('include("' .. filepath .. '")\n')
      end, { buffer = args.buf, desc = "Include File in Right Terminal" })

      -- Lightweight "variables workspace": captures varinfo() from the right terminal's
      -- Julia REPL and shows it in a floating window. Not a debugger.
      vim.keymap.set("n", "<leader>bv", function()
        require("cincinperin.misc.julia").show_variables()
      end, { buffer = args.buf, desc = "Show Julia Variables" })
    end,
  })
end)
