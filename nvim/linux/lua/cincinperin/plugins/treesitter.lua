MiniMisc.now(function()
  local augroup = vim.api.nvim_create_augroup("cincinperin_treesitter", { clear = true })

  vim.pack.add({
    "https://github.com/neovim-treesitter/nvim-treesitter",
    "https://github.com/neovim-treesitter/treesitter-parser-registry",
  })

  local filetypes = {
    "bash",
    "c",
    "cpp",
    "diff",
    "julia",
    "lua",
    "luadoc",
    "markdown",
    "markdown_inline",
    "vim",
    "vimdoc",
    "yaml",
  }

  -- Keep parsers up to date whenever the plugin itself updates.
  vim.api.nvim_create_autocmd("PackChanged", {
    group = augroup,
    callback = function(ev)
      local name, kind = ev.data.spec.name, ev.data.kind
      if name == "nvim-treesitter" and kind == "update" then
        if not ev.data.active then
          vim.cmd.packadd("nvim-treesitter")
        end
        vim.cmd("TSUpdate")
      end
    end,
  })

  require("nvim-treesitter").install(filetypes)

  -- Turn on tree-sitter highlighting for these filetypes.
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = filetypes,
    callback = function()
      vim.treesitter.start()
    end,
  })

  -- Use tree-sitter-based indentation everywhere except Julia, which gets its
  -- own custom indent file in Phase 4.
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = vim.tbl_filter(function(ft) return ft ~= "julia" end, filetypes),
    callback = function()
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end)
