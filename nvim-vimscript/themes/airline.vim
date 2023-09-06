" Use OneDark theme
let g:airline_theme='onedark'

" Status bar configuration
let g:airline_powerline_fonts=1 " Enable Poweline fonts
let g:airline_extensions = ['branch', 'tabline']
let g:airline_left_sep=''
let g:airline_left_alt_sep=''
let g:airline_right_sep=''
let g:airline_right_alt_sep=''

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

let g:airline_symbols.branch=''
let g:airline_symbols.colnr=' CN:'
let g:airline_symbols.readonly=''
let g:airline_symbols.linenr=' LN:'
let g:airline_symbols.maxlinenr='☰ '
let g:airline_symbols.dirty='⚡'

" Branch
let g:airline#extensions#branch#enabled=1
let g:airline#extensions#branch#empty_message=''
let g:airline#extensions#branch#vcs_checks=[]

" Tabline
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#show_buffers=0
let g:airline#extensions#tabline#alt_sep=1
let g:airline#extensions#tabline#tab_nr_type=1
let g:airline#extensions#tabline#left_sep=''
let g:airline#extensions#tabline#left_alt_sep=''
let g:airline#extensions#tabline#right_sep=''
let g:airline#extensions#tabline#right_alt_sep=''
let g:airline#extensions#tabline#formatter='unique_tail'
