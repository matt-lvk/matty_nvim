require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "clangd", "marksman" }
vim.lsp.enable(servers)

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
  },
})

-- Use Pyright instead of pylsp
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
      },
    },
  },
})
vim.lsp.enable "pyright"

-- Ruff LSP: live lint diagnostics (unused imports, undefined vars, etc.)
-- Formatting is handled by conform.nvim (ruff_format) instead
vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  settings = {
    ruff = {
      lint = { enable = true },
      format = { enable = false },
    },
  },
})
vim.lsp.enable "ruff"

-- read :h vim.lsp.config for changing options of lsp servers
