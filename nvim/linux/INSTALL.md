# System Dependencies — Bootstrap Checklist

Everything outside of Neovim itself that this config (`~/.config/nvim/`) needs to actually
work, for setting up a fresh machine. Nothing in here is installed *by* Neovim/`vim.pack` —
these are prerequisites `vim.pack`-managed plugins call out to. Kept up to date alongside
`CHEATSHEET.md` whenever something new gets installed.

Commands below use `eopkg` (Solus). On another distro, substitute your package manager —
the package *names* may differ slightly, but everything listed is a mainstream package.

## Neovim itself

- **Neovim ≥ 0.12** (this config was built and tested on 0.12.5). Several things in this
  config were specifically adjusted to work on *stable* Neovim rather than nightly (a few
  APIs ronisbr's original config relies on are nightly-only) — an older stable release may
  hit the same class of issue again.

## Core CLI tools

```bash
sudo eopkg install tree-sitter-cli
```
Required by `nvim-treesitter` (the new rewrite this config uses) to build/compile parsers.
Also needs a working **C compiler** (`gcc`/`cc`) — virtually always already present on a dev
machine, but worth checking (`command -v cc`).

```bash
sudo eopkg install ripgrep fd
```
Required by `mini.pick` for `<leader>ff` (find files) and `<leader>fg` (live grep).

`git` and `curl` — required by `vim.pack` itself (cloning plugins) and by
`typst-preview.nvim`/`markdown-preview.nvim` (both download their own pre-built preview
binaries on first use, via `curl`, with no separate Node.js/Deno runtime required to run the
downloaded binary itself). Practically always already present, not worth a dedicated
install step.

## LSP servers (none of these auto-install)

**Lua** — precompiled binary, not packaged for Solus. Check
https://github.com/LuaLS/lua-language-server/releases for the latest version and adjust the
URL below:
```bash
mkdir -p ~/.local/share/lua-language-server
curl -L https://github.com/LuaLS/lua-language-server/releases/download/<VERSION>/lua-language-server-<VERSION>-linux-x64.tar.gz | tar xz -C ~/.local/share/lua-language-server
ln -sf ~/.local/share/lua-language-server/bin/lua-language-server ~/.local/bin/lua-language-server
```

**Typst** — precompiled binary (`tinymist`), also serves as the Typst preview backend.
Check https://github.com/Myriad-Dreamin/tinymist/releases for the latest `tinymist-linux-x64`
asset:
```bash
curl -L -o ~/.local/bin/tinymist https://github.com/Myriad-Dreamin/tinymist/releases/download/<VERSION>/tinymist-linux-x64
chmod +x ~/.local/bin/tinymist
```

**Julia** — needs `LanguageServer.jl` installed into its own dedicated environment (NOT
auto-installed by `nvim-lspconfig`, despite some other LSP servers being self-installing):
```bash
julia --project=~/.julia/environments/nvim-lspconfig -e 'using Pkg; Pkg.add("LanguageServer")'
```

Both `~/.local/bin` and `~/.julia/bin` (see Runic below) need to be on `PATH`.

## Julia tooling

**Runic** (the Julia code formatter, also what this project's own CI enforces):
```bash
julia -e 'using Pkg; Pkg.Apps.add("Runic")'
```
Installs to `~/.julia/bin/runic` — make sure `~/.julia/bin` is on `PATH` (this machine has it
via `~/.config/zsh/.zsh_paths`, sourced from `.zshrc` — **note**: `.zshrc`-sourced PATH
entries are only visible to *interactive* shells, so anything checking `executable('runic')`
non-interactively, including Neovim launched in odd ways, needs this confirmed working from
inside a real running Neovim session, not just a terminal `command -v` check).

## LaTeX

TeX Live itself (providing `pdflatex`, `latexmk`) is assumed already installed — this config
doesn't set it up, just uses it.

**`latexindent`** (LaTeX formatter, bundled with TeX Live but **not functional out of the
box** — missing Perl modules):
```bash
sudo eopkg install perl-yaml-tiny perl-file-homedir
```

**Okular** (PDF viewer, for `vimtex` forward/inverse search — Zathura is the other common
choice if preferred instead, also in Solus repos):
```bash
sudo eopkg install okular
```
Inverse search (Okular → jump back to Neovim) also needs a one-time **manual GUI setting** in
Okular itself — see `CHEATSHEET.md`'s LaTeX section for the exact steps and command.

## Git tooling

```bash
sudo eopkg install lazygit
```

## Fonts

```bash
sudo eopkg install font-firacode-nerd
```
A Nerd Font is required for `mini.icons`' glyphs (file-type icons in `mini.pick`/`mini.files`)
and the custom statusline's icons/separators. Any Nerd Font variant works, not specifically
FiraCode — this is just what's on this machine. Your terminal emulator also needs to be
configured to actually use it as its font.
