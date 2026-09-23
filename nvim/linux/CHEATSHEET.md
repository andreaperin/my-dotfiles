# Neovim Cheatsheet — Custom Config

Everything here is **new** on top of vanilla Vim/Neovim. Source of truth:
`~/.config/nvim/lua/cincinperin/`.

Leader = `<Space>`. Local-leader = `\`.

## Personal Cheatsheet Popup (`lua/cincinperin/misc/help.lua`)

`<leader>h` opens a floating quick-reference of every custom command, grouped by area.
Close with `q` or `<Esc>`. Keep it in sync with this file when a keymap changes.

## Buffers & Windows

| Key | Does |
|---|---|
| `<leader>pv` | Open netrw (built-in file browser) at the current file's directory — largely superseded by `mini.files`/`mini.pick` below, but still works |
| `<leader>bd` | Delete current buffer, keep window layout (unlike `:bd`) |
| `<leader>bw` | Close all buffers except the current one |
| `[b` / `]b` | Previous / next buffer |
| `[t` / `]t` | Previous / next tab |
| `<leader>wn` | New tab (`:tabnew`) |
| `<leader>wc` | Close current tab (`:tabclose`) |
| `<leader>wo` | Close all tabs except the current one (`:tabonly`) |
| `Ctrl-w v` / `:vsplit` | *(vanilla Vim)* Open a vertical split |
| `Ctrl-w s` / `:split` | *(vanilla Vim)* Open a horizontal split |
| `Ctrl-w h/j/k/l` | *(vanilla Vim)* Move focus between splits — new splits open below/right by default now (`splitbelow`/`splitright`) |

Two files side by side: `Ctrl-w v` to split, then `<leader>e` in the new window.

## Editing & Misc

| Key | Does |
|---|---|
| `<Esc>` (normal mode) | Clear search highlighting (in addition to leaving insert mode) |
| `↑` / `↓` (normal, visual, insert) | Move by *visual* line (`gk`/`gj`) instead of logical line — only matters when `wrap` is on and a line spans multiple screen rows |
| `<leader>z` | Toggle soft wrap for the current window (`wrap` + `linebreak`) — display only, no newlines inserted, like VS Code's Alt+Z. Global default is `wrap = false`; `gq`/`gqap` is the separate *hard* wrap at `textwidth = 92` |
| `<leader>ac` | Copy `file:line` of the cursor position to the clipboard (e.g. for pasting a reference into a chat) |
| `<C-j>` (normal, insert) | Jump to and select the next `<++>` placeholder marker |

## Editor Behavior (no keymap — just how things behave differently now)

| Option | Effect |
|---|---|
| `clipboard = unnamedplus` | Yank/delete/paste use the system clipboard by default, no `"+`/`"*` prefix needed |
| `ignorecase` + `smartcase` | Searches are case-insensitive, unless the pattern contains an uppercase letter |
| `breakindent` | Wrapped lines keep the indentation of the original line |
| `cursorline` | The line the cursor is on is highlighted |
| `inccommand = nosplit` | `:s/foo/bar/` previews the substitution live as you type it |
| `list` + `listchars` | Tabs, trailing whitespace, and non-breaking spaces render as visible characters |
| `virtualedit = block` | In visual-block mode, the cursor can move past the end of short lines |
| `winborder = rounded` | Every floating window (LSP hover, pickers, etc.) gets a rounded border by default |
| `textwidth = 92` / `colorcolumn = 93` | Wrap target for `gq`; the color column marks one past it |
| `hlsearch = true` | (Changed earlier, for `hlslens`) search matches stay highlighted until cleared |
| `spelllang = en` | Spell-checking dictionary is pre-configured and auto-downloaded on startup if missing (see Spellcheck below) — spell-check itself is still off by default, `:set spell` to turn it on |

## Spellcheck

`spelllang = "en"` globally (`set.lua`); the dictionary (`en.utf-8.spl`, ~600KB)
auto-downloads on first use. Spell-check is **off by default** — `:set spell` per buffer.

Generic "en" only: the Vim runtime repo ships no pre-built regional dictionaries
(`en_gb`, `en_us`), just `.diff` patches for `:mkspell` against a source that's been
dead for years.

| Key | Does *(vanilla Vim, once `:set spell` is on)* |
|---|---|
| `]s` / `[s` | Jump to next/previous flagged word |
| `z=` | Show spelling suggestions for the word under the cursor |
| `zg` / `zw` | Mark word under cursor as good/known or as wrong |
| `zug` / `zuw` | Undo a `zg` / `zw` |
| `:echo spellbadword()` | Why the word under the cursor is flagged: `bad` (not in dictionary), `rare`, `local` (another region's spelling), `caps` (capitalisation) — matching the `SpellBad`/`SpellRare`/`SpellLocal`/`SpellCap` highlight groups |

With generic `en` no word is ever flagged `local`, so British and American spellings are
both accepted. vimtex marks command names as non-spell regions, so only prose is checked
in `.tex` files.

## Autocmds (`lua/cincinperin/autocmds.lua`)

Automatic behavior, no keymaps to remember — except one: **`q`** now closes several built-in/plugin windows instantly (`checkhealth`, `help`, `:LspInfo`, `notify`, quickfix, `:StartupTime`, `undotree`) without needing `:q` or leaving them cluttering your buffer list.

| Behavior | Trigger |
|---|---|
| Terminal buffers close automatically | Any terminal (including the floating/right terminals) whose shell process exits with status 0 |
| Yanked text briefly flashes (200ms, `Visual` highlight) | Any yank (`y`, `yy`, etc.) |
| Markdown `#`/`##`/... heading lines get a subtle highlight | Any `.md` file — mostly redundant now that `render-markdown.nvim` handles this better, kept as a fallback |

## Multicursor (`multicursors.nvim`)

Stable Neovim has no native multicursor, so: `smoka7/multicursors.nvim` +
`nvimtools/hydra.nvim`.

| Key | Does |
|---|---|
| `<leader>m` (normal or visual) | Select the word under the cursor (or the visual selection) and enter multicursor mode |
| `<C-a>` (inside multicursor mode) | Select every other occurrence in the buffer |
| `n` / `N` (inside multicursor mode) | Step to next/previous occurrence one at a time, instead of selecting all |
| `i` / `a` / `c` / `d` (inside multicursor mode) | Insert / append / change / delete — applies to every active selection simultaneously |
| `<Esc>` (inside multicursor mode) | Clear selections, back to normal mode |

More inside multicursor mode (align, macros, tree-sitter extend): `:h multicursors`.

## Terminal

`lua/cincinperin/misc/terminal.lua`. Three independent, persistent `zsh` sessions —
hiding one doesn't kill its shell; reopening resumes it.

| Key | Does |
|---|---|
| `<F5>` / `<leader>tf` | Toggle a centered floating terminal (~80% of screen), with a dimmed backdrop and background tinted to match the active colorscheme |
| `<F6>` / `<leader>tr` | Toggle a persistent right-side vertical split terminal (80 cols) |
| `<leader>tb` | Toggle a persistent bottom horizontal split terminal (15 rows) — coexists independently alongside the right terminal, e.g. for a second shell/process/log while the right one runs a REPL |
| `<Esc>` once (inside a terminal) | Sent literally to the program running inside (e.g. `less`, a nested `vim`) rather than exiting terminal-mode |
| `<Esc>` twice quickly | Exits terminal-mode back to normal mode |
| `<C-w> h/j/k/l` (inside the right or bottom terminal) | Move focus to the window in that direction, without leaving terminal-mode first |
| `<leader>ts` (normal: buffer; visual: selection) | Send buffer/selection text to the **right** terminal specifically, without switching focus to it |
| `<leader>ti` | Same as `<leader>ts`, but also focuses the right terminal afterward |

`<leader>ts`/`<leader>ti` (and Julia's `<leader>bf`) always target the **right** terminal.
The bottom one is a spare shell; nothing is ever sent to it.

## Git — LazyGit (`lua/cincinperin/misc/lazygit.lua`)

Floating lazygit, theme-synced to the active colorscheme. Commit authors all render in
one legible color instead of LazyGit's random per-author colors.

| Key / Command | Does |
|---|---|
| `<leader>gg` / `:LazyGit` | Open lazygit in a floating window |
| `<leader>gl` | Open lazygit directly to the commit log view |

## Shared floating-window helper (`lua/cincinperin/misc/float.lua`)

Infrastructure shared by the floating terminal and lazygit: a dimmed backdrop window plus
a content window, both tinted from the active colorscheme. The tint comes from `Pmenu`'s
background, not `Normal` — the editor runs transparent (`bg=none`), so `Normal` has no real
color to work from. Other floats (`mini.pick`, `mini.files`, LSP hover) stay transparent.

## Search

`hlsearch` is on — matches stay highlighted until cleared (`<Esc>` or `:noh`).

| Key | Does |
|---|---|
| `/pattern<CR>`, `n` / `N` | Search forward/backward, jump to next/previous match — now shows a `[x/y]` match-count indicator (`nvim-hlslens`) next to the current match |
| `*` / `#` | Search forward/backward for the exact word under the cursor (whole-word match) |
| `g*` / `g#` | Like `*`/`#`, but matches the word as a substring too |

## Undo History

| Key | Does |
|---|---|
| `<leader>u` | Toggle the Undotree window (visual undo history, not just linear undo) |
| (inside Undotree) `j`/`k` | Move through history states |
| (inside Undotree) `<CR>` | Restore buffer to the state under the cursor |
| `Ctrl-w h` / `Ctrl-w l` | Move focus into/out of the Undotree split |

## Colorschemes

Active by default: **kanagawa** (transparent background), set via `ColorMyPencils()`.
Installed alternatives, switch anytime with `:colorscheme <name>`:

- `gruvbox`
- `tokyonight`
- `rose-pine`
- `brightburn`

## Fun

| Command | Does |
|---|---|
| `:CellularAutomaton make_it_rain` | Matrix-style rain animation over the buffer (needs tree-sitter highlighting for the buffer's filetype — any key exits) |
| `:CellularAutomaton game_of_life` | Conway's Game of Life animation over the buffer |

## Fuzzy Finding (`mini.pick`)

Needs `ripgrep` + `fd` installed (done).

| Key | Does |
|---|---|
| `<leader>ff` | Find files in the current directory |
| `<leader>fg` | Live grep across the project |
| `<leader>fb` | Find among open buffers |
| `<leader>fh` | Search help tags |
| (inside picker) `<C-n>` / `<C-p>` | Move selection down/up |
| (inside picker) `<CR>` | Open selected item |
| (inside picker) `<Esc>` | Cancel |

## File Explorer (`mini.files`)

| Key | Does |
|---|---|
| `<leader>e` | Open the file explorer |
| `l` | Go into a directory, or preview a file (explorer stays open) |
| `L` | Go into a file **and close** the explorer (jump straight into editing) |
| `<CR>` | *(custom)* same as `L` — go in and close, works on files or directories |
| `h` | Go out to the parent directory |
| `q` | Close the explorer |
| `g.` | Toggle showing hidden/dotfiles (starts hidden every time the explorer opens) |
| `g?` | Explorer's own help (shows every mapping, including defaults not listed here) |

## Which-Key Popup (`mini.clue`)

Press and hold **`<leader>`**, **`g`**, a mark key (`` ` ``/`'`/`"`), `Ctrl-w` or `z` and
pause — a popup shows every mapping that follows, custom and built-in alike (it discovers
real mappings, so `gq`, `gc` etc. appear with no config). Width set to `"auto"`.

## Command Line (`mini.cmdline`)

Automatic, no keymaps. Bare defaults.

- Autocomplete popup as you type a command, capped to 10 rows.
- Autocorrects mistyped command names and options.
- Typing a range (`:10,20`, `:%`) shows a floating peek of those lines.

## Completion (`mini.completion`)

Automatic in insert mode: popup after **700ms** idle (up from the 100ms default, so a
snippet prefix like `env<Tab>` expands instead of the popup stealing that `<Tab>`).
`<C-e>` cancels it.

| Key | Does |
|---|---|
| `<Tab>` | Snippet jump forward (if in a snippet) → else next item in popup → else expand a uniquely-matching snippet → else literal tab |
| `<S-Tab>` | Snippet jump backward (if in a snippet) → else previous item in popup → else literal shift-tab |
| `<C-n>` / `<C-p>` | Move down/up the suggestion list (still works directly, `<Tab>`/`<S-Tab>` just wrap it) |
| `<C-y>` | Confirm/accept selection |
| `<C-e>` | Cancel, close the popup |

An active snippet session always wins `<Tab>`/`<S-Tab>` over the completion popup, which
auto-triggers while typing inside a placeholder — otherwise `<Tab>` would navigate that
incidental popup instead of jumping the tabstop.

## Snippets (`mini.snippets`)

Filetype-scoped — `snippets/latex.json` only loads in `.tex`/`.plaintex` files,
`snippets/julia.json` only in `.jl` files. Triggered by `<Tab>` above — type the prefix,
hit `<Tab>` to expand, `<Tab>`/`<S-Tab>` to move between placeholders.

### LaTeX (`snippets/latex.json`)

| Prefix | Expands to |
|---|---|
| `bf` | `\textbf{<selection>}` |
| `it` | `\textit{<selection>}` |
| `tt` | `\texttt{<selection>}` |
| `mbf` | `\mathbf{<selection>}` |
| `env` | `\begin{<name>} ... \end{<name>}` (name is mirrored to both ends) |
| `fig` | `\begin{figure}` block with `\includegraphics`, `\caption`, `\label` |
| `tab` | `\begin{table}` block with `\caption`, `\label`, `\begin{tabular}` |

`bf`/`it`/`tt`/`mbf` read `${TM_SELECTED_TEXT}`, i.e. select text in Visual mode first,
then type the prefix and `<Tab>` to wrap the selection.

### Julia (`snippets/julia.json`)

| Prefix | Expands to |
|---|---|
| `desc` | A boxed `#`-banner "Description" comment section |
| `IRZ` | Full file header: institution/department/location, `Author:` line, then the `desc` banner |

## Git (`mini.diff` + `mini.git`)

Only active on files inside a git repo with commit history.

| Key / Command | Does |
|---|---|
| (automatic) | Sign-column markers (`+`/`~`/`-`) for added/changed/deleted lines vs. `HEAD` |
| `<leader>go` | Toggle an inline diff overlay showing old text alongside new |
| `:Git <args>` | Thin fugitive-like wrapper, e.g. `:Git blame`, `:Git log` |

## Text Editing

| Key | Module | Does |
|---|---|---|
| `<M-h/j/k/l>` (normal or visual) | `mini.move` | Move current line / selection left/down/up/right |
| `gS` | `mini.splitjoin` | Toggle a bracketed construct (call args, table, etc.) between one-line and multi-line |
| `<leader>cw` | `mini.trailspace` | Trim trailing whitespace from the buffer |
| `ga` then a char (visual mode) | `mini.align` | Interactive alignment on that character, e.g. `ga=` aligns on `=` |
| `<leader>xb` (custom, `remap.lua`) | — | Converts 2 lines into a centered box: line 1 = fill/border pattern (e.g. `*`), line 2 = text to center, both padded to column 92 |

## Visual Aids

| Feature | Module | Does |
|---|---|---|
| Vertical guide line | `mini.indentscope` | Animated indicator of the current indent scope, automatic |
| `TODO`/`FIXME`/`HACK`/`NOTE` highlighting | `mini.hipatterns` | Automatic, highlights those words wherever they appear |
| Hex color preview | `mini.hipatterns` | Automatic, hex codes like `#ff0000` get their background colored to match |
| Trailing-whitespace highlight | `mini.trailspace` | Automatic, shows what `<leader>cw` would trim |

## Julia

| Feature | Does |
|---|---|
| Type `\alpha`, `\beta`, `\in`, `\_1`, etc. then any non-identifier character (space, punctuation, ...) | (`julia-vim`) Auto-converts to the Unicode symbol (`α`, `β`, `∈`, subscript `₁`, ...) — same escapes as the Julia REPL itself |
| `<CR>` / `o` / `O` / `gg=G` inside a `f(;` keyword-only argument block split across lines | (`after/indent/julia.lua`) Indents kwarg lines by one `shiftwidth`, aligns the closing `)` back to the opening line — everything else falls through to normal tree-sitter indentation. Known narrow edge case: a genuinely blank line left between the `(;` and the `)` gets over-indented; a real kwarg line in between works correctly. |
| `gq` on a `-`/`*`/`+` bullet line (e.g. in a docstring) | (`after/ftplugin/julia.lua`) Reflows the bullet's text to fit `textwidth`, indenting continuation lines by one `shiftwidth`. On non-bullet text, falls back to LSP range-formatting if the attached server supports it, then to Vim's default `gq`. |
| `gcc` / `gc{motion}` / visual `gc` (Neovim's **native**, built-in comment toggle — no plugin) | Toggles a `# ...` comment for Julia (any filetype gets the right comment syntax automatically via `commentstring`) |
| `<leader>cf` | Format the current buffer with **Runic** (the same formatter this project's CI enforces) |
| (automatic) | Runic also runs on every `:w` of a `.jl` file — formatting happens before the write, so the saved file is already formatted |
| `<leader>bf` | `include("<current file>")` in the right terminal (`<leader>tr`) — start a Julia REPL there first (just type `julia`). Unlike `<leader>ts` (send buffer text), this re-reads from disk, so error stacktraces get correct line numbers and any relative `include()`/`@__DIR__` in the file works correctly |
| `<leader>bv` | Show current variables (`varinfo()`) from the right terminal's Julia REPL in a floating window — a lightweight "workspace" view, not a debugger. Requires a Julia REPL already running there, same as `<leader>bf` |

## LaTeX (`vimtex`)

PDF viewer: **Zathura** (`eopkg install zathura-mupdf`). vimtex loads only when a `.tex`
file is opened (lazy, on filetype). `conceallevel = 0` locally — LaTeX syntax
(e.g. `\alpha`, math delimiters) is never hidden behind rendered symbols.

Default mappings live under `<localleader>` = `\`:

| Key | Does |
|---|---|
| `\ll` | Compile (`latexmk`, non-continuous — you trigger each compile manually) |
| `\lv` | Forward search: open/jump to the current cursor location in Zathura, highlighting the target line |
| `\lt` | Toggle the table-of-contents sidebar |
| `\lc` | Clean auxiliary build files |
| `\le` | Show compilation errors (quickfix list) |
| `<leader>cf` | Format with **`latexindent`** (needs `perl-yaml-tiny`/`perl-file-homedir`) |
| (automatic) | `latexindent` also runs on every `:w` of a `.tex` file, same as Julia's Runic |

**Inverse search** (Zathura → jump back to the source line in Neovim): **Ctrl+Click** in the
PDF. No zathura config needed — vimtex passes the editor command via `zathura -x`.

Two settings in `plugins/vimtex.lua` make that work:

```lua
vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_callback_progpath = "nvim -c 'packadd vimtex'"
```

`packadd` is required: the inverse search runs in a second, headless nvim where vimtex's
lazy `FileType tex` load never happens, so `VimtexInverseSearch` wouldn't exist. Everything
SyncTeX resolves is a line box, so the highlight is a line, never a single word.

## Typst (`typst-preview.nvim` + `after/ftplugin/typst.lua`)

`typst-preview.nvim` loads only when a `.typ` file is opened (lazy, on filetype). First
use downloads its preview binaries via `curl` — give it a moment the very first time.

| Key / Command | Does |
|---|---|
| `<leader>ct` | Toggle the live preview on/off |
| `:TypstPreview` | Start the preview (`:TypstPreview slide` for slide mode instead of document mode) |
| `:TypstPreviewStop` | Stop the preview |
| `:TypstPreviewSyncCursor` | Scroll the preview to the current cursor position |
| `:TypstPreviewFollowCursor` / `:TypstPreviewNoFollowCursor` | Toggle whether the preview auto-scrolls as you move the cursor (on by default) |
| `<leader>cc` | Compile to a standalone PDF (`typst compile`, not the live preview) — auto-saves first if the buffer has unsaved changes, since compiling reads from disk. Errors from a bad compile show via `vim.notify` with the full compiler output |

Preview updates live, and clicking in it jumps the cursor to the matching source position
— bidirectional and automatic, unlike vimtex's manual forward/inverse search.

## Markdown (`render-markdown.nvim` + `markdown-preview.nvim`)

Both load only when a `.md` file is opened (lazy, on filetype).

**Prose-editing settings** (`after/ftplugin/markdown.lua`): `wrap`/`linebreak`/`breakindent`
on (global default is `wrap = false`), wrapped lines marked with `↳ `. `textwidth = 0` and
`colorcolumn` cleared. `shiftwidth`/`tabstop = 2`.

**In-buffer prettification** (`render-markdown.nvim`), automatic: styled headers, real
bullets, boxed code blocks, checkbox glyphs.

**Live browser preview** (`markdown-preview.nvim`):

| Key / Command | Does |
|---|---|
| `<leader>cm` | Toggle a live preview in your default browser, synced scroll as you move the cursor |
| `:MarkdownPreview` / `:MarkdownPreviewStop` | Start / stop directly |

First use downloads a ~17MB preview-server binary via `curl`. KaTeX and Mermaid work out
of the box. One-way sync only (cursor → preview scroll).

## AI Assistant (`99`)

Shells out to a CLI AI agent per invocation — one-shot, not a persistent chat.

| Key | Does |
|---|---|
| `<leader>9v` (visual) | Send the selection + a prompt (you'll be asked for it) to the AI, replace the selection with the result |
| `<leader>9s` | Search the project with a prompt, results land in the quickfix list |
| `<leader>9x` | Stop all in-flight requests |
| `<leader>9o` | Open the last interaction's results (quickfix for search/visual) |
| `<leader>9l` | View the most recent request/response logs |
| `<leader>9m` | Switch model for the current provider (`mini.pick`, custom — `99` only ships telescope/fzf-lua pickers by default) |
| `<leader>9p` | Switch provider entirely (`mini.pick`, custom, same reason) — resets to that provider's default model |

**Default provider: Claude** (via the `claude` CLI), default model `claude-sonnet-4-5`.
Switch to `OpenCodeProvider`/`CursorAgentProvider`/`GeminiCLIProvider`/`KiroProvider` any
time with `<leader>9p`, no restart needed — each needs its own CLI tool installed and on
`PATH` to actually work (only `claude` is set up so far).

**Safety note**: the Claude provider always runs `claude --dangerously-skip-permissions`,
hardcoded in `99`'s source and not switchable. Every `<leader>9v`/`<leader>9s` is a fully
autonomous subprocess — no confirmation for file edits or shell commands it runs.

The `<leader>9m`/`<leader>9p` pickers are a custom module
(`lua/cincinperin/misc/ninetynine_pickers.lua`) over `99.extensions.pickers`, swapping only
the UI for `vim.ui.select`.

## Language Servers (LSP)

Active for: Lua (`lua_ls`), Julia (`julials`), Typst (`tinymist`). No LSP for LaTeX — that's
handled by `vimtex` directly, coming in a later phase. No `clangd` (not needed, no C/C++ work).

**One-time manual install needed on any new machine** (none of these auto-install):
- `lua_ls`: binary release from https://github.com/LuaLS/lua-language-server, symlinked onto `PATH`
- `tinymist`: binary release from https://github.com/Myriad-Dreamin/tinymist, onto `PATH`
- `julials`: **not automatic** despite some LSP servers being self-installing — run
  `julia --project=~/.julia/environments/nvim-lspconfig -e 'using Pkg; Pkg.add("LanguageServer")'`
  once; first attach after that is still slower than later ones (precompilation)

| Key | Does |
|---|---|
| `K` | Hover documentation |
| `gra` | Code actions |
| `grd` | Go to definition |
| `grD` | Go to declaration |
| `gre` | Show diagnostics for the current line |
| `gri` | Go to implementation |
| `grn` | Rename symbol |
| `grr` | Find references (via `mini.extra`'s LSP picker) |
| `:LspLog` | Open the Nvim LSP client log in a new tab |
| `:LspJuliaActivateEnv [path]` | (Julia only) switch which Julia project environment the language server uses |

## Startup

`mini.starter` shows a dashboard when `nvim` runs with no file argument: centered "N" logo,
footer with plugin count and startup time, action list. Filter by typing, or `<C-n>`/`<C-p>`;
`<CR>` runs the highlighted action.

| Action | Runs |
|---|---|
| Find File | `mini.pick` file search |
| New File | Opens a new empty buffer in insert mode |
| Find Text | `mini.pick` live grep |
| Recent Files | `mini.pick` old-files list |
| Config | Opens `~/.config/nvim` in `mini.files` |
| LazyGit | Opens the floating LazyGit |
| Update Plugins | `vim.pack.update()` |
| Quit | `:qa` |

Below the actions: your 8 most recent files, listed directly.

Startup is staged via `mini.misc`'s scheduler (`now`/`later`/`on_event`/`on_filetype`):
colors, tree-sitter, `mini.files` and `mini.starter` immediately; most of `mini.nvim`, LSP,
hlslens and multicursors right after, without blocking first paint; `mini.snippets`/
`mini.cmdline` on first Insert/Cmdline use; markdown/typst/vimtex on the first buffer of
that filetype.

## Statusline (`lua/cincinperin/misc/statusline.lua`)

Colors pulled live from the active colorscheme, recolored on `:colorscheme`. Left to
right:

| Segment | Shows |
|---|---|
| Mode badge | `NORMAL` / `INSERT` / `VISUAL` / etc., color-coded |
| Folder | Current working directory's last path component |
| Macro recording | Appears only while recording a macro (`q<letter>`) — icon + register |
| Filename | `[+]` prefix if the buffer has unsaved changes |
| Filetype | Icon + filetype name, plus `, #<branch>` if the file is in a git repo (via `mini.git`) |
| LSP clients | Names of LSP servers attached to the current buffer, in brackets |
| Diagnostics | Per-severity counts (error/warn/info/hint), icon + number, only shown when nonzero |
| *(right-aligned from here)* | |
| Multicursor badge | Pill showing the active cursor count from `multicursors.nvim` — only appears with `<leader>m` multicursor session active, hidden otherwise |
| Visual selection info | `[NL]` (lines) or `[NL MC]` (lines x columns) while in Visual/Visual-block mode |
| Cursor position | Column:line and scroll percentage |
| Tab list | Only shown with 2+ tabs open — `[1 | 2 | 3]`, current tab highlighted |

Read-only buffers and the quickfix list get simplified renders; `mini.starter`'s dashboard
has no statusline at all.

## Julia Syntax Highlighting Extension (`after/queries/julia/highlights.scm`)

Automatic. Extends (not replaces) the base Julia query with 3 captures: assignment targets
(`x` in `x = ...`), macro calls (`@assert`, ...), and string interpolation (`$x`/`$(expr)`).

## Syntax & Indentation (tree-sitter)

Parsers installed: bash, c, cpp, diff, julia, lua, luadoc, markdown, markdown_inline, vim,
vimdoc, yaml. Highlighting is active automatically for all of them.
Tree-sitter-based indentation is wired for all of them **except Julia** (which will get its own
custom indent file later).
