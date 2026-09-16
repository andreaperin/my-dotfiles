# Neovim Cheatsheet — Custom Config

Everything in this file is **new** on top of vanilla Vim/Neovim — plain motions, operators,
registers, etc. aren't repeated here. Organized by feature area, in the order it was added.
Kept up to date as the config grows; see `~/.config/nvim/lua/cincinperin/` for the actual
source of truth if anything here ever looks stale.

Leader = `<Space>`. Local-leader = `\`.

## Personal Cheatsheet Popup (`lua/cincinperin/misc/help.lua`)

`<leader>h` opens a floating quick-reference of every custom command in this config,
grouped by area (Buffers, Tabs, Terminal, Send to Terminal, Formatting, Julia, LaTeX,
Typst, Markdown, Git, Search, Multicursor, Finding Things, Undo History, Misc). Close
with `q` or `<Esc>`. Not a replacement for this file — this is the fast, scannable
version for "what was that key again?" while actually editing; this file has the full
prose/rationale/gotchas. Keep both in sync when a keymap changes.

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

Decided to stick with vanilla split commands rather than adding `mini.files`-specific
split-and-open mappings (ronisbr doesn't have those either — he also just uses plain
`Ctrl-w`). Workflow for opening two files side by side: `Ctrl-w v` to split, then `<leader>e`
in the new window to browse to the second file.

## Editing & Misc

| Key | Does |
|---|---|
| `<Esc>` (normal mode) | Clear search highlighting (in addition to leaving insert mode) |
| `↑` / `↓` (normal, visual, insert) | Move by *visual* line (`gk`/`gj`) instead of logical line — only matters when `wrap` is on and a line spans multiple screen rows |
| `<leader>ac` | Copy `file:line` of the cursor position to the clipboard (e.g. for pasting a reference into a chat) |
| `<C-j>` (normal, insert) | Jump to and select the next `<++>` placeholder marker — not useful yet, no snippets exist to place them (pending `mini.snippets`) |

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

`spelllang = "en"` is set globally (`set.lua`), and its dictionary file
(`en.utf-8.spl`, ~600KB) auto-downloads from the Vim runtime repository the first
time it's missing — one-time cost, checked (cheaply) on every startup after that.
Spell-check itself is **off by default** everywhere (matches ronisbr's own config) —
turn it on per-buffer with `:set spell`, or `:set nospell` to turn back off.

Only the generic "en" dictionary is used, not a region-specific one (`en_gb`,
`en_us`, etc.) — confirmed the Vim runtime repository doesn't actually distribute
pre-built regional dictionaries, only `.diff` patches meant for building one from
Hunspell source files via `:mkspell`, and the official recipe for obtaining that
source data points to a URL that's been dead for years. Revisit if a reliable
`en_GB` dictionary source ever turns up.

| Key | Does *(vanilla Vim, once `:set spell` is on)* |
|---|---|
| `]s` / `[s` | Jump to next/previous misspelled word |
| `z=` | Show spelling suggestions for the word under the cursor |
| `zg` | Mark word under cursor as a good/known word |
| `zw` | Mark word under cursor as wrong |

## Autocmds (`lua/cincinperin/autocmds.lua`)

Automatic behavior, no keymaps to remember — except one: **`q`** now closes several built-in/plugin windows instantly (`checkhealth`, `help`, `:LspInfo`, `notify`, quickfix, `:StartupTime`, `undotree`) without needing `:q` or leaving them cluttering your buffer list.

| Behavior | Trigger |
|---|---|
| Terminal buffers close automatically | Any terminal (including the floating/right terminals) whose shell process exits with status 0 |
| Yanked text briefly flashes (200ms, `Visual` highlight) | Any yank (`y`, `yy`, etc.) |
| Markdown `#`/`##`/... heading lines get a subtle highlight | Any `.md` file — mostly redundant now that `render-markdown.nvim` handles this better, kept as a fallback |

## Multicursor (`multicursors.nvim`)

Neovim 0.12.5 doesn't have the native multicursor feature ronisbr uses (nightly-only, 0.13+),
so this is a third-party plugin instead (`smoka7/multicursors.nvim` + its dependency
`nvimtools/hydra.nvim`).

| Key | Does |
|---|---|
| `<leader>m` (normal or visual) | Select the word under the cursor (or the visual selection) and enter multicursor mode |
| `<C-a>` (inside multicursor mode) | Select every other occurrence in the buffer |
| `n` / `N` (inside multicursor mode) | Step to next/previous occurrence one at a time, instead of selecting all |
| `i` / `a` / `c` / `d` (inside multicursor mode) | Insert / append / change / delete — applies to every active selection simultaneously |
| `<Esc>` (inside multicursor mode) | Clear selections, back to normal mode |

Much more available inside multicursor mode (align selections, macros, tree-sitter-aware
extend mode, etc.) — see `:h multicursors` once installed.

## Terminal

Custom module (`lua/cincinperin/misc/terminal.lua`), a simplified port of ronisbr's — using
`zsh` (not his `nu`/nushell). Three independent, persistent terminal sessions — closing/
hiding one doesn't kill its shell or affect the others, reopening resumes the same session.
The floating terminal shares the `misc/float.lua` module below (backdrop + theme-tinted
background).

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

`<leader>ts`/`<leader>ti` (and Julia's `<leader>bf`, see Julia section) always target the
right terminal only — the bottom terminal is a separate, independent shell, nothing sends
code to it automatically. This is a deliberate choice, not a limitation: simpler mental
model, one terminal is always "the REPL," the other is just a spare terminal.

## Git — LazyGit (`lua/cincinperin/misc/lazygit.lua`)

Floating lazygit, theme-synced to the active colorscheme (regenerates automatically on
`:colorscheme` change) — shares the same `misc/float.lua` backdrop+tinting module as the
floating terminal above, for visual consistency. Commit authors all render in one consistent,
legible color (`Normal`'s real foreground) instead of LazyGit's default behavior of assigning
a random color per author — ronisbr's own config doesn't set this either, so this is a
standalone fix, not something ported from him.

| Key / Command | Does |
|---|---|
| `<leader>gg` / `:LazyGit` | Open lazygit in a floating window |
| `<leader>gl` | Open lazygit directly to the commit log view |

## Shared floating-window helper (`lua/cincinperin/misc/float.lua`)

Not a feature by itself — infrastructure shared by the floating terminal and lazygit (and
anything else built as a floating window later). Gives a backdrop window (dimmed padding)
behind the content window, with both tinted to a color derived from the active colorscheme:
lightened for dark themes, darkened toward warm tones for light ones. Since the main editor
intentionally uses a transparent background (`bg=none`, for terminal transparency), the tint
is derived from `Pmenu`'s background instead of `Normal`/`NormalFloat` — `Pmenu` stays solid
in every installed colorscheme, giving the tinting math a real color to work from. This only
affects floats built through this module; other floats (`mini.pick`, `mini.files`, LSP hover,
`mini.clue`, ...) are untouched and remain transparent as before.

## Search

`hlsearch` is on (changed from the original tutorial config's `false`, specifically to make
`hlslens` useful) — search matches stay highlighted after a search until cleared (`<Esc>`, per
the existing `remap.lua` mapping, or `:noh`).

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

Press and hold **`<leader>`**, **`g`**, a mark key (`` ` ``/`'`/`"`), `Ctrl-w`, or `z`, and pause —
a popup shows every mapping that follows from there, both custom and Neovim built-ins (e.g.
`gq`/`gw` for formatting and `gc`/`gcc` for commenting show up automatically here too — no
config needed, `mini.clue` discovers real mappings on its own, not just an explicit list).
Popup window width set to `"auto"` (was a fixed 30 columns by default, truncating most
descriptions with `...`).

## Command Line (`mini.cmdline`)

Automatic — no keymaps, just a better `:` experience. Bare defaults, nothing configured.

- Autocomplete popup as you type a command (enhances vanilla `<Tab>`-completion) — popup
  height capped to 10 rows while the cmdline is open (uncapped again in insert-mode
  completion elsewhere).
- Autocorrects mistyped words that must come from a fixed set (command names, options).
- Typing a range (e.g. `:10,20` or `:%`) shows a floating peek of those lines before you
  hit Enter.

## Completion (`mini.completion`)

Automatic in insert mode — no trigger key, a popup appears as you type after 700ms idle
(tuned up from the 100ms default so it doesn't beat a snippet prefix's `<Tab>` to the
punch, e.g. typing `env<Tab>` fast enough now expands instead of the popup stealing that
`<Tab>` to navigate itself). If you ever get a popup open mid-typing and just want it
gone, `<C-e>` cancels it and restores what you actually typed.

| Key | Does |
|---|---|
| `<Tab>` | Snippet jump forward (if in a snippet) → else next item in popup → else expand a uniquely-matching snippet → else literal tab |
| `<S-Tab>` | Snippet jump backward (if in a snippet) → else previous item in popup → else literal shift-tab |
| `<C-n>` / `<C-p>` | Move down/up the suggestion list (still works directly, `<Tab>`/`<S-Tab>` just wrap it) |
| `<C-y>` | Confirm/accept selection |
| `<C-e>` | Cancel, close the popup |

An active snippet session always wins `<Tab>`/`<S-Tab>` over the completion popup, even if
the popup happens to be open (it auto-triggers while typing plain text inside a
placeholder) — otherwise `<Tab>` would silently navigate the incidental popup instead of
jumping the tabstop. Confirmed by testing real keystroke-by-keystroke via RPC, not just
reading the code.

## Snippets (`mini.snippets`)

Filetype-scoped — `snippets/latex.json` only loads in `.tex`/`.plaintex` files,
`snippets/julia.json` only in `.jl` files. Triggered by `<Tab>` above — type the prefix,
hit `<Tab>` to expand, `<Tab>`/`<S-Tab>` to move between placeholders.

### LaTeX (ported from ronisbr's 7 general-purpose ones; his Julia snippets were mostly
personal, see below for the 2 that were worth keeping)

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
| `desc` | A boxed `#`-banner "Description" comment section (ported verbatim from ronisbr) |
| `IRZ` | Full file header: institution/department/location lines, `Author:` line, then the same Description banner as `desc` — tailored with your own name/email/affiliation, not a port (ronisbr's `inpe-header` had his own identity hardcoded, so this was rebuilt from scratch for you) |

Skipped `makieaxisconf` (Makie.jl plot-styling boilerplate — this project doesn't use Makie).

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

Ported two sibling commands from ronisbr (`<leader>xa`/`<leader>xf`, character-fill/left-align
macros) but removed them — `xa` had a real correctness bug (destroyed line content on
realistic input, root cause never fully pinned down) and `xf`, while working, wasn't judged
useful enough to keep. `xb` is the one genuinely valuable, confirmed-working piece.

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

PDF viewer: **Okular** (installed via `eopkg install okular`). vimtex loads only when a
`.tex` file is opened (lazy, on filetype). `conceallevel = 0` locally — LaTeX syntax
(e.g. `\alpha`, math delimiters) is never hidden behind rendered symbols.

Default mappings live under `<localleader>` = `\`:

| Key | Does |
|---|---|
| `\ll` | Compile (`latexmk`, non-continuous — you trigger each compile manually) |
| `\lv` | Forward search: open/jump to the current cursor location in Okular |
| `\lt` | Toggle the table-of-contents sidebar |
| `\lc` | Clean auxiliary build files |
| `\le` | Show compilation errors (quickfix list) |
| `<leader>cf` | Format the current buffer with **`latexindent`** (TeX Live's bundled formatter — needed `perl-yaml-tiny`/`perl-file-homedir` installed via `eopkg` first, wasn't functional out of the box) |
| (automatic) | `latexindent` also runs on every `:w` of a `.tex` file, same as Julia's Runic |

**Inverse search** (Okular → jump back to the source line in Neovim): one-time manual setup
required in Okular itself (can't be done from the Neovim config side) —

1. Okular → Settings → Configure Okular → Editor → set editor to **Custom Text Editor**, with
   command:
   ```
   nvim --headless "%f" -c "VimtexInverseSearch %l '%f'"
   ```
   (the `"%f"` file argument is required — without it, `nvim --headless` never opens a `.tex`
   file, so its `FileType` event never fires, so vimtex — which only loads on that event —
   never loads, so the `VimtexInverseSearch` command doesn't exist yet when Okular tries to
   run it)
2. In Okular, switch to Browse mode (`Ctrl+1`, Tools menu — this is also the default mouse
   mode), then **Shift+Click** on text in the PDF to jump back to that line in Neovim. A plain
   click/drag in this mode pans the page rather than selecting text — that's expected, not a
   bug; text selection needs the separate Selection tool (`Ctrl+2`).

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

Preview updates live as you type, and clicking in the preview jumps the cursor to the
corresponding place in the source (cross-jump, similar in spirit to vimtex's forward/inverse
search, but automatic/bidirectional rather than a manual keypress). `<leader>cc` is separate
from the preview — it's for when you want an actual `.pdf` file on disk, independent of
whether the preview is running.

## Markdown (`render-markdown.nvim` + `markdown-preview.nvim`)

Both load only when a `.md` file is opened (lazy, on filetype).

**Prose-editing settings** (`after/ftplugin/markdown.lua`, always active regardless of the
two plugins above): `wrap`/`linebreak`/`breakindent` on (global default is `wrap = false`
everywhere else) — long lines soft-wrap at word boundaries, wrapped continuation lines
show a `↳ ` marker and match the original line's indent. `textwidth = 0` (no hard column
limit) and `colorcolumn` cleared, since prose isn't meant to hit a fixed line-length target
the way code is. `shiftwidth`/`tabstop = 2`, matching the config's other prose/markup
filetypes.

**In-buffer prettification** (`render-markdown.nvim`), automatic, no keymaps: headers get
bold/colored styling with icons, bullet points render as actual bullets, fenced code
blocks get a boxed background, checkboxes (`- [ ]` / `- [x]`) render as real checkbox
glyphs — all using the plugin's default styling.

**Live browser preview** (`markdown-preview.nvim`), same idea as Typst's `<leader>ct`
above:

| Key / Command | Does |
|---|---|
| `<leader>cm` | Toggle a live preview in your default browser, synced scroll as you move the cursor |
| `:MarkdownPreview` / `:MarkdownPreviewStop` | Start / stop directly |

First use downloads a pre-built preview-server binary (~17MB, via `curl` — same one-time-cost
pattern as Typst/vimtex's own first-run downloads); after that it's instant. Supports
KaTeX math and Mermaid diagrams out of the box. Unlike Typst's preview, this is one-way
sync only (cursor → preview scroll) — no click-in-browser-to-jump-to-source, that's a
Typst-specific feature its tooling happens to support.

## AI Assistant (`99`)

Shells out to a real CLI AI agent per invocation (not a persistent chat/background
process) — one-shot: you trigger it, it runs, result comes back. Loads on `later`
(non-blocking startup, same tier as most other plugins).

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

**Real safety note, not hypothetical**: the Claude provider always runs `claude
--dangerously-skip-permissions` — this is hardcoded in `99`'s own source, not something a
config option can turn off. Every `<leader>9v`/`<leader>9s` call through it is a one-shot,
fully-autonomous subprocess for that single invocation — no per-action confirmation for
file edits or shell commands it decides to run while satisfying that one request. Consciously
accepted, not an oversight — matters if you're about to trigger it on something sensitive.

The `<leader>9m`/`<leader>9p` pickers are a small custom module
(`lua/cincinperin/misc/ninetynine_pickers.lua`) built on `99`'s own
`99.extensions.pickers` data/apply logic (the same one its telescope/fzf-lua extensions
use) — only the picker UI itself is swapped for `vim.ui.select`, already routed to
`MiniPick.ui_select` elsewhere in this config, so no new fuzzy-finder dependency was added
just for this.

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

Completion popups (`mini.completion`, already documented above) now also pull in real
LSP-backed suggestions on top of buffer words.

## Startup

`mini.starter` shows a customized dashboard automatically when you run `nvim` with no file
argument: a centered "N" logo, a footer with the loaded-plugin count and startup time (in
ms), and a bulleted action list. Navigate by typing letters to fuzzy-filter, arrows/`<C-n>`/
`<C-p>`, or clicking; `<CR>` to run the highlighted action.

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

Startup is staged via `mini.misc`'s scheduler (`now`/`later`/`on_event`/`on_filetype`,
matching ronisbr's own pattern): colors, tree-sitter, `mini.files`, and `mini.starter`
itself are ready immediately; most of `mini.nvim` (pick, clue, completion, diff, git,
etc.), LSP, hlslens, and multicursors load right after, without blocking the first paint;
`mini.snippets`/`mini.cmdline` don't load at all until you actually enter Insert/Cmdline
mode for the first time in a session; markdown/typst/vimtex only load on the first buffer
of that filetype. Nothing about how these features work changed, only when they load —
the practical effect is a faster-feeling startup and `mini.clue`'s which-key popup now
correctly appears on the `mini.starter` dashboard itself (previously silently didn't).

## Statusline (`lua/cincinperin/misc/statusline.lua`)

Custom statusline, ported from ronisbr, colors pulled live from whatever colorscheme is
active (see Colorschemes section — switches with `:colorscheme <name>`, statusline
recolors automatically). No keymaps — purely informational, left to right:

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

Read-only buffers and the quickfix list get their own simplified renders instead of the
above. `mini.starter`'s dashboard has no statusline at all (hidden by filetype).

Adapted, not a literal copy, in one place: ronisbr's multicursor badge reads Neovim's
*native* nightly multicursor state (which also has a "follow mode" with a different badge
color) — we use the `multicursors.nvim` plugin instead (stable Neovim has no native
multicursor yet), which has no follow-mode concept, so the badge here only ever has the
one color variant and just shows a cursor count.

## Julia Syntax Highlighting Extension (`after/queries/julia/highlights.scm`)

Automatic, no keymap — extends (not replaces) the base Julia tree-sitter highlight query with
3 extra captures: assignment targets (`x` in `x = ...`) get a distinct highlight from other
variable references, macro calls (`@assert`, `@inbounds`, ...) get their own highlight
distinct from regular function calls, and string interpolation (`$x`/`$(expr)` inside
strings) gets its own highlight standing out from the surrounding string text.

## Syntax & Indentation (tree-sitter)

Parsers installed: bash, c, cpp, diff, julia, lua, luadoc, markdown, markdown_inline, vim,
vimdoc, yaml. Highlighting is active automatically for all of them.
Tree-sitter-based indentation is wired for all of them **except Julia** (which will get its own
custom indent file later).
