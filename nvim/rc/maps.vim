" Leaders
map <SPACE> <LEADER>

" Exit insert mode
inoremap jk <ESC> 
inoremap <ESC> <NOP>

" Exit buffer
nnoremap <LEADER>q :quit<CR>

" Save buffer to file
nnoremap <C-s> :write<CR>
inoremap <C-s> <ESC>:write<CR>a
