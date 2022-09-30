call plug#begin('~/.local/share/nvim/plugged')

" IDE 
Plug 'preservim/nerdtree' 											" File system explorer
Plug 'Xuyuanp/nerdtree-git-plugin'							" Show git status flags on NERDTree
Plug 'ryanoasis/vim-devicons'										" Adds filetype-specific icons to NERDTree files and folders
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'	" Adds syntax highlighting to NERDTree based on filetype 
Plug 'tpope/vim-fugitive'												" Git plugin
Plug 'sheerun/vim-polyglot'											" A collection of language packs

" Themes
Plug 'joshdick/onedark.vim'		" OneDark theme (Atom default theme)

" Status Bar
Plug 'vim-airline/vim-airline'					" Lean & mean status/tabline for vim
Plug 'vim-airline/vim-airline-themes'		" Official theme repository for vim-airline

" Find and Replace
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }	" Latest version of the fuzzy finder FZF
Plug 'junegunn/fzf.vim'															" Fuzzy finder that uses the FZF available in the system
Plug 'gabrielpoca/replacer.nvim'                    " Makes a quickfix window editable, allowing changes to both the content of a file as well as its path

" Conquer of Completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

