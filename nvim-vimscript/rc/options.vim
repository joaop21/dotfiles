""" General Options
set autowrite             " write the contents of the file, if it has been modified
set nocompatible	        " disable compatibility with old vim 
set clipboard=unnamedplus " connects with the system clipboard for all operations (yank, select, delete, etc)


""" Backup
set nobackup      " doesn't make a backup before overwriting a file
set nowritebackup " doesn't make a write backup before overwriting a file


""" Identation and Tabs
set expandtab			  " uses the correct number of spaces to insert a tab
set shiftround      " round indent to multiple of 'shiftwidth'
set shiftwidth=2    " number of spaces to use for each step of (auto)indent
set smartindent     " do smart autoindenting when starting a new line
set softtabstop=2   " number of spaces that a <Tab> counts for while performing editing	operations
set tabstop=2       " number of spaces that a <Tab> in the file counts for


""" Layout
set cursorline      " highlight the text line of the cursor with CursorLine
set signcolumn=yes  " when and how to draw the signcolumn 
set splitbelow      " splitting a window will put the new window below the current one
set splitright      " splitting a window will put the new window right of the current one


""" Lines
set linebreak       " wrap long lines at a character in 'breakat' rather than at the last character that fits on the screen
set number 				  " show line numbers
set relativenumber  " show the line number relative to the line with the cursor in front of each line
set scrolloff=5     " minimal number of screen lines to keep above and below the cursor


""" Mouse
set mouse=a   " Enables mouse support for all modes


""" Search
set gdefault        " all matches in a line are substituted instead of one
set ignorecase 		  " ignore case in search
set showmatch       " when a bracket is inserted, briefly jump to the matching one
set smartcase       " override the 'ignorecase' option if the search pattern contains upper case characters


""" Swap Files
set noswapfile		  " disable the swapfile
set updatetime=300  " if this many milliseconds nothing is typed the swap file will be written to disk. Also used for the CursorHold autocommand event.


""" Undo Buffer
set history=100     " history of commands and previous search patterns
