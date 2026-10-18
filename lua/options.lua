require "nvchad.options"

-- add yours here!

local o = vim.o

-- Add npm global binaries to PATH
local npm_global = vim.fn.expand "~/.npm-global/bin"
vim.env.PATH = npm_global .. ":" .. vim.env.PATH

-- Python provider (pynvim) lives in a dedicated venv, so it works with
-- Homebrew's externally-managed python. Create it with:
--   python3 -m venv ~/.local/share/nvim/py && ~/.local/share/nvim/py/bin/pip install pynvim debugpy
local nvim_py = vim.fn.stdpath "data" .. "/py/bin/python"
if vim.fn.executable(nvim_py) == 1 then
  vim.g.python3_host_prog = nvim_py
  vim.g.loaded_python3_provider = nil -- NvChad disables it; magma/molten need it
end

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
