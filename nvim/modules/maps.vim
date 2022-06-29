" Leaders
map <SPACE> <leader>

" Exit insert mode
inoremap jk <ESC> 
inoremap <ESC> <NOP>

" Exit buffer
nnoremap <leader>q :quit<CR>

" Save buffer to file
nnoremap <C-s> :write<CR>
inoremap <C-s> <ESC>:write<CR>a
