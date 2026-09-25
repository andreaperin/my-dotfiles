" vimtex's listings module covers \lstset, \lstinline and lstlisting, but not
" \lstdefinelanguage -- so its body is parsed as LaTeX and a lone `$` in it
" (e.g. alsoother={$}) opens a math zone that never closes. Both arguments are
" opaque; the body nests braces, hence the self-referencing region.
syntax match texCmdLstDefLang "\\lstdefinelanguage\>"
      \ nextgroup=texLstDefLangName skipwhite skipnl
syntax region texLstDefLangName matchgroup=texDelim start="{" end="}" contained
      \ nextgroup=texLstDefLangBody skipwhite skipnl
syntax region texLstDefLangBody matchgroup=texDelim start="{" end="}" contained
      \ contains=texLstDefLangNest
syntax region texLstDefLangNest start="{" end="}" contained transparent
      \ contains=texLstDefLangNest

highlight def link texCmdLstDefLang texCmd
highlight def link texLstDefLangName Normal
highlight def link texLstDefLangBody Normal
