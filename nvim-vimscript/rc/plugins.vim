call plug#begin('~/.local/share/nvim/plugged')

" IDE 
Plug 'preservim/nerdtree' 											" File system explorer
Plug 'Xuyuanp/nerdtree-git-plugin'							" Show git status flags on NERDTree
Plug 'ryanoasis/vim-devicons'										" Adds filetype-specific icons to NERDTree files and folders
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'	" Adds syntax highlighting to NERDTree based on filetype 
Plug 'tpope/vim-fugitive'												" Git plugin

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
Plug 'elixir-lsp/coc-elixir', {'do': 'yarn install --frozen-lockfile && yarn prepack'}
Plug 'neoclide/coc-eslint', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-highlight', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-java', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-prettier', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}

" Languages
let g:polyglot_disabled = ['java']              " Polyglot doesn't support java. I need to disable it before the plugin
Plug 'sheerun/vim-polyglot'											" A collection of language packs
Plug 'tomlion/vim-solidity'                     " Syntax files for Solidity
Plug 'uiiaoo/java-syntax.vim', {'for': 'java'}  " Syntax Highlighting for Java

" Terminal
Plug 'voldikss/vim-floaterm'  " Terminal in a floating/popup window

" Git Copilot
Plug 'github/copilot.vim' " Github Copilot

call plug#end()

