local augroup = vim.api.nvim_create_augroup("cincinperin_autocmds", { clear = true })

-- Close some buffers with specific filetypes using `q`.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = {
    "checkhealth",
    "help",
    "lspinfo",
    "notify",
    "qf",
    "startuptime",
    "undotree",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Automatically close terminal buffers when the process exits with status 0.
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  desc = "Auto-close terminal buffer on successful exit",
  callback = function(args)
    if vim.v.event.status == 0 and vim.api.nvim_buf_is_valid(args.buf) then
      vim.cmd({ cmd = "bdelete", args = { args.buf }, bang = true })
    end
  end,
})

-- Highlight the text affected by yank and put operations.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Highlight markdown headings.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup,
  pattern = { "*.md" },
  callback = function()
    vim.fn.matchadd("Special", "#[^# ]\\+")
    vim.fn.matchadd("Special", "#[^#]\\+#")
  end,
})
