MiniMisc.later(function()
  vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig",
  })

  -- Give every LSP server the completion capabilities mini.completion knows how to use.
  vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })

  -- Lua ---------------------------------------------------------------------------------------

  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = {
          checkThirdParty = false,
          library = { vim.env.VIMRUNTIME },
        },
      },
    },
  })

  -- Julia -------------------------------------------------------------------------------------

  vim.lsp.config("julials", {})

  -- Typst -------------------------------------------------------------------------------------

  vim.lsp.config("tinymist", {})

  vim.lsp.enable({ "lua_ls", "julials", "tinymist" })

  -- Keymaps set on every buffer an LSP server attaches to.
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("cincinperin_lsp_attach", { clear = true }),
    callback = function(event)
      local function nmap(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
      end

      nmap("K", vim.lsp.buf.hover, "Hover Documentation")
      nmap("gra", vim.lsp.buf.code_action, "Code Actions")
      nmap("grd", vim.lsp.buf.definition, "Definition")
      nmap("grD", vim.lsp.buf.declaration, "Declaration")
      nmap("gre", vim.diagnostic.open_float, "Line Diagnostics")
      nmap("gri", vim.lsp.buf.implementation, "Implementation")
      nmap("grn", vim.lsp.buf.rename, "Rename")
      nmap("grr", function() MiniExtra.pickers.lsp({ scope = "references" }) end, "References")
    end,
  })

  vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd.tabnew()
    vim.cmd.log("lsp")
  end, { desc = "Open the Nvim LSP client log in a new tab." })
end)
