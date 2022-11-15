" Leaders
map <space> <leader>

" Exit insert mode
inoremap jk <esc> 
inoremap kj <esc> 
inoremap <esc> <nop>

" Exit buffer
nnoremap <leader>q :quit<CR>

" Save buffer to file
nnoremap <C-s> :write<CR>
inoremap <C-s> <esc>:write<CR>a

" Search
nnoremap <silent> <leader>a :Ag <C-R><C-W><CR>
nnoremap <leader>sw :%s/\<<C-r><C-w>\>//g<Left><Left>

" Clear Highlights
nnoremap <leader><CR> :noh<CR>
