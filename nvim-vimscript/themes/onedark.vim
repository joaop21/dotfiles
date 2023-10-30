hi Comment cterm=italic

let g:onedark_hide_endofbuffer=1 " Set to 1 if you want to hide end-of-buffer filler lines (~) for a cleaner look; 0 otherwise (the default).

let g:onedark_terminal_italics=1 " Set to 1 if your terminal emulator supports italics; 0 otherwise (the default).

let g:onedark_termcolors=256 " Set to 256 for 256-color terminals (the default), or set to 16 to use your terminal emulator's native 16 colors.

syntax on
colorscheme onedark

" checks if your terminal has 24-bit color support
if (has("termguicolors"))
    set termguicolors
    hi LineNr ctermbg=NONE guibg=NONE
endif
