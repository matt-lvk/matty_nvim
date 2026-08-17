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

-- Python-specific indent-based folding
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.foldmethod = "indent"
    vim.opt_local.foldlevel = 99  -- Start with all folds open
    vim.opt_local.foldnestmax = 10
  end,
})

-- For other files, try treesitter if available
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldenable = true
o.foldlevel = 99
