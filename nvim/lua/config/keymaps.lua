vim.g.mapleader = " "

function map(mode, shortcut, command)
	vim.keymap.set(mode, shortcut, command, { noremap = true, silent = true })
end

function nmap(shortcut, command)
	map("n", shortcut, command)
end

function imap(shortcut, command)
	map("i", shortcut, command)
end

function vmap(shortcut, command)
	map("v", shortcut, command)
end

function tmap(shortcut, command)
	map("t", shortcut, command)
end

function smap(shortcut, command)
	map("s", shortcut, command)
end

-- Exit insert mode
imap("jk", "<esc>")
imap("kj", "<esc>")
imap("<esc>", "<nop>")

-- Exit buffer
nmap("<leader>q", ":quit<cr>")

-- Save buffer to file
nmap("<C-s>", ":update!<cr>")
imap("<C-s>", "<C-o>:update!<cr><esc>")

-- Move between panes
nmap("<C-h>", ":wincmd h<cr>")
nmap("<C-j>", ":wincmd j<cr>")
nmap("<C-k>", ":wincmd k<cr>")
nmap("<C-l>", ":wincmd l<cr>")

-- Clear Highlights
nmap("<leader>,", ":noh<cr>")

-- Search (and replace)
nmap("<leader>sw", [[:%s/\<<C-r><C-w>\>//g<left><left>]])
