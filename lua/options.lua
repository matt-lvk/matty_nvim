require "nvchad.options"

-- add yours here!

local o = vim.o

-- Add npm global binaries to PATH
local npm_global = vim.fn.expand "~/.npm-global/bin"
vim.env.PATH = npm_global .. ":" .. vim.env.PATH

-- Set terminal title to "nvim | <repo-name>"
o.title = true
o.titlestring = "nvim | " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

-- Auto-reload files changed externally
o.autoread = true
