-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local delete_map = vim.keymap.del

-- Exit Insert Mode
map("i", "jk", "<esc>", { desc = "Exit Insert Mode", silent = true, noremap = true })
map("i", "kj", "<esc>", { desc = "Exit Insert Mode", silent = true, noremap = true })
map("i", "<esc>", "<nop>", { desc = "Disable Escape in Insert Mode", silent = true, noremap = true })

-- Clear search
delete_map({ "i", "n" }, "<esc>", { desc = "Escape and Clear hlsearch" })
map({ "n" }, "<leader>,", "<cmd>noh<cr>", { desc = "Clear hlsearch" })
