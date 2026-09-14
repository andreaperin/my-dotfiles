vim.opt.guicursor = ""
vim.opt.mouse = "a"

vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.breakindent = true
vim.opt.cursorline = true
vim.opt.inccommand = "nosplit"
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.virtualedit = "block"
vim.opt.winborder = "rounded"
vim.opt.showmode = false
vim.opt.textwidth = 92
vim.opt.shortmess:append("cq")
vim.opt.shell = "/bin/zsh"

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "93"

vim.opt.spelllang = "en"

-- Auto-download the spell dictionary file(s) for `spelllang` if missing, from the Vim
-- runtime repository. Note: the runtime repo only ships one generic "en" dictionary, not
-- region-specific ones (en_gb.utf-8.spl doesn't exist there -- confirmed, not assumed);
-- genuinely region-locked dictionaries would need building from source via `:mkspell`.
do
  local spell_dir = vim.fn.stdpath("data") .. "/site/spell/"
  local base_url = "https://ftp.nluug.nl/pub/vim/runtime/spell/"

  -- Download a spell file from the Vim runtime repository into `spell_dir`. The file is
  -- first saved to a `.tmp` path and atomically renamed on success to avoid leaving a
  -- truncated file that would prevent future retries.
  local function download(file)
    vim.notify("Downloading spell file: " .. file, vim.log.levels.INFO)
    vim.fn.mkdir(spell_dir, "p")
    local tmp = spell_dir .. file .. ".tmp"

    vim.net.request(base_url .. file, { outpath = tmp }, vim.schedule_wrap(function(err)
      if err then
        vim.uv.fs_unlink(tmp, function() end)
        vim.notify("Failed to download spell file: " .. file, vim.log.levels.ERROR)
        return
      end

      vim.uv.fs_rename(tmp, spell_dir .. file, function()
        vim.schedule(function()
          vim.notify("Spell file downloaded: " .. file, vim.log.levels.INFO)
          vim.cmd("silent! edit")
        end)
      end)
    end))
  end

  -- Check whether the UTF-8 spell file for `lang` exists and is non-empty. Uses only the
  -- two-letter language prefix (e.g. "en" for "en_us") since that is the filename
  -- convention used by the Vim runtime repository. Downloads the file if it is missing or
  -- zero-size.
  local function ensure_dict(lang)
    local file = lang:sub(1, 2) .. ".utf-8.spl"
    local path = spell_dir .. file
    local stat = vim.uv.fs_stat(path)
    if not stat or stat.size == 0 then
      download(file)
    end
  end

  for _, lang in ipairs(vim.split(vim.o.spelllang, ",")) do
    ensure_dict(lang)
  end
end
