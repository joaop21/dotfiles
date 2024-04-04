--
-- GLOBAL EDITOR VARIABLES
--

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

--
-- VIM OPTIONS
--

local opt = vim.opt

-- General Options
opt.autowrite = true            -- write the contents of the file, if it has been modified
opt.compatible = false        	-- disable compatibility with old vim 
opt.clipboard = "unnamedplus" 	-- connects with the system clipboard for all operations (yank, select, delete, etc)


-- Backup
opt.backup = false      -- doesn't make a backup before overwriting a file
opt.writebackup = false -- doesn't make a write backup before overwriting a file


-- Identation and Tabs
opt.expandtab = true	  -- uses the correct number of spaces to insert a tab
opt.shiftround = true   -- round indent to multiple of 'shiftwidth'
opt.shiftwidth = 2    	-- number of spaces to use for each step of (auto)indent
opt.smartindent = true  -- do smart autoindenting when starting a new line
opt.softtabstop = 2   	-- number of spaces that a <Tab> counts for while performing editing	operations
opt.tabstop= 2        	-- number of spaces that a <Tab> in the file counts for


-- Layout
opt.cursorline = true     -- highlight the text line of the cursor with CursorLine
opt.signcolumn = "yes"    -- when and how to draw the signcolumn 
opt.splitbelow = true     -- splitting a window will put the new window below the current one
opt.splitright = true     -- splitting a window will put the new window right of the current one
opt.termguicolors = true  -- enables 24-bit RGB color


-- Lines
opt.linebreak = true        -- wrap long lines at a character in 'breakat' rather than at the last character that fits on the screen
opt.number = true 				  -- show line numbers
opt.relativenumber = true   -- show the line number relative to the line with the cursor in front of each line
opt.scrolloff = 5           -- minimal number of screen lines to keep above and below the cursor


-- Mouse
opt.mouse = "a"   -- Enables mouse support for all modes


-- Search
opt.gdefault = true       -- all matches in a line are substituted instead of one
opt.ignorecase = true 		-- ignore case in search
opt.showmatch = true      -- when a bracket is inserted, briefly jump to the matching one
opt.smartcase = true      -- override the 'ignorecase' option if the search pattern contains upper case characters


-- Swap Files
opt.swapfile = false		  -- disable the swapfile
opt.updatetime = 300      -- if this many milliseconds nothing is typed the swap file will be written to disk. Also used for the CursorHold autocommand event.


-- Undo Buffer
opt.history = 100     -- history of commands and previous search patterns
