" +----------+
" | Mappings |
" +----------+

nnoremap <silent> <c-t> :FloatermToggle<CR>
tnoremap <silent> <c-t> <C-\><C-n>:FloatermToggle<CR>

" +---------------+
" | Customisation |
" +---------------+

"let g:floaterm_shell = '&shell'
let g:floaterm_title = ''
let g:floaterm_wintype = 'float'
let g:floaterm_width = 0.8
let g:floaterm_height = 0.8
let g:floaterm_position = 'center'
let g:floaterm_borderchars = ''
let g:floaterm_rootmarkers = ['.project', '.git', '.hg', '.svn', '.root']
let g:floaterm_opener = 'split'
let g:floaterm_autoclose = 1
let g:floaterm_autohide = 1
let g:floaterm_autoinsert = v:true

" +-----------+
" | Behaviour |
" +-----------+

