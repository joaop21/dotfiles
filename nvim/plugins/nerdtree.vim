" +----------+
" | Mappings |
" +----------+

nnoremap <leader>n :NERDTreeToggleVCS<CR>

" +---------------+
" | Customisation |
" +---------------+

let NERDTreeNaturalSort=1
let NERDTreeIgnore=['\.git$', '\.DS_Store']
let NERDTreeShowHidden=1

" +-----------+
" | Behaviour |
" +-----------+

autocmd StdinReadPre * let s:std_in=1

" Start NERDTree when Vim starts with a directory argument.
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') | execute 'NERDTreeToggleVCS' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

" Start NERDTree. If a file is specified, move the cursor to its window.
autocmd VimEnter * NERDTreeToggleVCS | if argc() > 0 || exists("s:std_in") | wincmd p | endif

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 | let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

