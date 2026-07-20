require "nvchad.options"

-- add yours here!

vim.g.loaded_python3_provider = nil
vim.g.python3_host_prog = "/Library/Frameworks/Python.framework/Versions/3.12/bin/python3"

local o = vim.o

-- Add npm global binaries to PATH
local npm_global = vim.fn.expand "~/.npm-global/bin"
vim.env.PATH = npm_global .. ":" .. vim.env.PATH
