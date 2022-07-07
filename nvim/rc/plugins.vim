call plug#begin('~/.local/share/nvim/plugged')

" IDE 
Plug 'preservim/nerdtree' 			" File system explorer
Plug 'Xuyuanp/nerdtree-git-plugin'		" Show git status flags on NERDTree
Plug 'ryanoasis/vim-devicons'			" Adds filetype-specific icons to NERDTree files and folders
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'	" Adds syntax highlighting to NERDTree based on filetype 
Plug 'tpope/vim-fugitive'			" Git plugin

" Themes
Plug 'joshdick/onedark.vim'		" OneDark theme (Atom default theme)

" Status Bar
Plug 'vim-airline/vim-airline'		" Lean & mean status/tabline for vim
Plug 'vim-airline/vim-airline-themes'	" Official theme repository for vim-airline

call plug#end()

