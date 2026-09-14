vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "<leader>h", function() require("cincinperin.misc.help").show() end, { desc = "Personal Cheatsheet" })

vim.keymap.set("n", "<Esc>", "<Esc><Cmd>noh<CR>", { desc = "Clear Search Highlight" })

vim.keymap.set({ "n", "v" }, "<Up>", "gk")
vim.keymap.set({ "n", "v" }, "<Down>", "gj")
vim.keymap.set("i", "<Up>", "<C-o>gk")
vim.keymap.set("i", "<Down>", "<C-o>gj")

vim.keymap.set("n", "[b", "<Cmd>bprevious<CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "]b", "<Cmd>bnext<CR>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bw", "<Cmd>%bd|e#|bd#<CR>", { desc = "Close All Buffers Except Current" })

vim.keymap.set("n", "[t", "<Cmd>tabprevious<CR>", { desc = "Previous Tab" })
vim.keymap.set("n", "]t", "<Cmd>tabnext<CR>", { desc = "Next Tab" })

vim.keymap.set("n", "<leader>wn", "<Cmd>tabnew<CR>", { desc = "New Tab" })
vim.keymap.set("n", "<leader>wc", "<Cmd>tabclose<CR>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader>wo", "<Cmd>tabonly<CR>", { desc = "Close Other Tabs" })

vim.keymap.set("n", "<leader>ac", function()
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")
  local ref = file .. ":" .. line
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
end, { desc = "Copy File:Line Reference to Clipboard" })

vim.keymap.set("n", "<C-j>", "/<++><CR>v3lc", { desc = "Change Next Placeholder" })
vim.keymap.set("i", "<C-j>", "<Esc>/<++><CR>v3lc", { desc = "Change Next Placeholder" })

-- Create a text block given the following input:
--   Current line: fill pattern.
--   Next line: text to be centered in the block.
vim.keymap.set(
  "n",
  "<leader>xb",
  "<Cmd>set lazyredraw<CR>" ..
  "<Cmd>set formatoptions-=ro<CR>" ..
  "0v$hy93P\"_D\"_d92|j0<Cmd>center<CR>0R<C-R>0<Esc>o<Esc>P<Cmd>right<CR>khjllv$hykpkyyjpjdd0" ..
  "<Cmd>set formatoptions+=ro<CR>" ..
  "<Cmd>set nolazyredraw<CR>",
  { desc = "Convert to Block", silent = true }
)
