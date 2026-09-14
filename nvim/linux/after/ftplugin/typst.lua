-- `typst compile` reads from disk, not the buffer -- save first if there are unsaved
-- changes, or the PDF would silently reflect stale content.
local function typst_compile()
  local bufnr = vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].modified then
    vim.api.nvim_buf_call(bufnr, function() vim.cmd("write") end)
  end

  local filepath = vim.api.nvim_buf_get_name(bufnr)

  vim.system({ "typst", "compile", filepath }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("Typst compile failed:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
        return
      end

      local pdf_name = vim.fn.fnamemodify(filepath, ":t:r") .. ".pdf"
      vim.notify("Compiled to " .. pdf_name, vim.log.levels.INFO)
    end)
  end)
end

vim.keymap.set("n", "<leader>cc", typst_compile, { buffer = true, desc = "Compile to PDF (typst)" })
