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

-- read :h vim.lsp.config for changing options of lsp servers
