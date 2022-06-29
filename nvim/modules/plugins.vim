call plug#begin('~/.local/share/nvim/plugged')

" IDE 
Plug 'preservim/nerdtree' 			" File system explorer
Plug 'Xuyuanp/nerdtree-git-plugin'		" Show git status flags on NERDTree
Plug 'ryanoasis/vim-devicons'			" Adds filetype-specific icons to NERDTree files and folders
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'	" Adds syntax highlighting to NERDTree based on filetype 

" Themes
Plug 'joshdick/onedark.vim'	" OneDark theme (Atom default theme)

call plug#end()
